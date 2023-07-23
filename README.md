# Codebreakers Stager

Welcome to Codebreakers Stager! This is a Python script that helps you create a batch file stager for downloading and executing PowerShell scripts invisibly on startup. It uses `pyfiglet` to display the "Codebreakers" ASCII art with a fancy font style and colored output for better aesthetics.

## Getting Started

To use Codebreakers Stager, you need to have Python 3 installed on your system. Additionally, make sure you have the required packages installed by running the following command:

```bash
pip install pyfiglet colorama

## Usage

1. Clone the repository to your local machine:

```bash
git clone https://github.com/Royalboy2000/codebreakers.git
cd codebreakers
python codestager.py

## Features

- [x] Prompt user for the download URL and filename for the stager.
- [x] Create a batch file stager for downloading and executing PowerShell scripts invisibly on startup.
- [x] Colored output for better visibility of script details.
- [ ] Support downloading files other than PowerShell scripts (e.g., EXEs, batch files).
- [ ] Option to specify the destination folder for downloaded files.
- [ ] Improve error handling for invalid inputs.
- [ ] Add support for system-wide startup folder to run the script for all users.
- [ ] Implement a progress bar for the file download process.
- [ ] Add support for downloading multiple files in one stager.

