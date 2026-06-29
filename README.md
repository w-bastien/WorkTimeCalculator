# WorkTimeCalculator

WorkTimeCalculator is a small Windows PowerShell/WPF desktop utility for calculating total working time from one or more start/end time ranges.

The application provides a bilingual French/English interface, live validation, automatic total updates, CSV export, and clipboard copy support. It is designed for quick daily time tracking without requiring a database or installation package.

## Features

- Add or remove as many work-time rows as needed.
- Enter start and end times in `HH:mm` format.
- Recalculate row durations and the overall total automatically as values change.
- Display totals as both `HH:mm` and decimal hours.
- Support overnight ranges by treating an end time earlier than the start time as the next day.
- Highlight missing or invalid fields with localized validation messages.
- Switch the UI between French and English.
- Export the current rows and totals to a semicolon-delimited CSV file.
- Copy the same CSV-formatted output to the clipboard.

## Requirements

- Windows with WPF support.
- Windows PowerShell 5.1 or PowerShell 7 on Windows.

> The script uses WPF assemblies (`PresentationFramework`, `PresentationCore`, and `WindowsBase`), so it is intended to run on Windows.

## Repository layout

```text
scripts/
  TempsTravail.ps1   # Main WorkTimeCalculator WPF script
README.md            # Project documentation
```

## Quick start

From the repository root, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\TempsTravail.ps1
```

Or, with PowerShell 7 on Windows:

```powershell
pwsh -File .\scripts\TempsTravail.ps1
```

The default language is French. To start the application in English, pass the `-Language` parameter:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\TempsTravail.ps1 -Language en
```

Supported language values are:

- `fr` for French.
- `en` for English.

## How to use

1. Launch `scripts/TempsTravail.ps1`.
2. Enter a start time and end time for each work period using `HH:mm` format, such as `08:30` or `17:15`.
3. Use **Add row** / **Ajouter une ligne** to add more periods.
4. Use **Delete** / **Supprimer** to remove a period.
5. Review the total at the bottom of the window.
6. Use **Export CSV** to save the current data to a CSV file, or **Copy** / **Copier** to place the CSV text on the clipboard.

## Time calculation behavior

Each row is calculated as:

```text
end time - start time
```

If the end time is earlier than the start time, the app assumes the shift crosses midnight. For example:

```text
22:00 to 06:00 = 08:00
```

Rows with missing or incorrectly formatted values are not included in the total until they are fixed.

## CSV output

CSV export and clipboard copy include:

- A localized header row.
- One row per entered time range.
- The `HH:mm` total.
- The decimal-hour total.
- Any validation message currently shown for invalid rows.

The generated CSV uses semicolons as separators so it works well with common French and European spreadsheet defaults.

## Development notes

There is currently no separate build step. The main application logic, UI definition, localization strings, validation, and export behavior are contained in `scripts/TempsTravail.ps1`.

When making changes, test on Windows because the UI depends on WPF.
