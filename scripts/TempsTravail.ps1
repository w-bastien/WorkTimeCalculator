param(
    [ValidateSet("fr", "en")]
    [string]$Language = "fr"
)

$script:SupportedLanguages = @("fr", "en")
$script:CurrentLanguage = $Language

$script:Translations = @{
    fr = @{
        WindowTitle = "Calcul du temps de travail"
        HeaderTitle = "Calcul du temps de travail"
        HeaderDescription = "Saisissez les heures au format HH:mm. Le total se met à jour automatiquement."
        AddRow = "+ Ajouter une ligne"
        Recalculate = "Recalculer"
        ExportCsv = "Export CSV"
        CopyClipboard = "Copier"
        Language = "Langue :"
        TotalLabel = "Total : "
        StartLabel = "Début :"
        EndLabel = "Fin :"
        DurationLabel = "Durée :"
        Delete = "Supprimer"
        TimeFormatTooltip = "Format attendu : HH:mm, exemple 08:30"
        CsvHeader = "Debut;Fin;Duree;Erreur"
        CsvTotal = "Total"
        CsvTotalDecimal = "Total decimal"
        CsvFilter = "Fichiers CSV (*.csv)|*.csv|Tous les fichiers (*.*)|*.*"
        CsvFileName = "temps-travail.csv"
        CsvExported = "CSV exporté"
        Copied = "Copie dans le presse-papiers"
        RequiredFields = "Champs obligatoires"
        StartRequired = "L'heure de début est obligatoire."
        EndRequired = "L'heure de fin est obligatoire."
        FormatRequired = "Format HH:mm requis"
        InvalidStart = "Format invalide. Exemple valide : 08:30."
        InvalidEnd = "Format invalide. Exemple valide : 17:15."
        Error = "Erreur"
        RowsToFixFormat = "{0} ligne(s) à corriger"
        LanguageFrench = "Français"
        LanguageEnglish = "English"
    }
    en = @{
        WindowTitle = "Worktime calculator"
        HeaderTitle = "Worktime calculator"
        HeaderDescription = "Enter times in HH:mm format. The total updates automatically."
        AddRow = "+ Add row"
        Recalculate = "Recalculate"
        ExportCsv = "Export CSV"
        CopyClipboard = "Copy"
        Language = "Language:"
        TotalLabel = "Total: "
        StartLabel = "Start:"
        EndLabel = "End:"
        DurationLabel = "Duration:"
        Delete = "Delete"
        TimeFormatTooltip = "Expected format: HH:mm, example 08:30"
        CsvHeader = "Start;End;Duration;Error"
        CsvTotal = "Total"
        CsvTotalDecimal = "Total decimal"
        CsvFilter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*"
        CsvFileName = "worktime.csv"
        CsvExported = "CSV exported"
        Copied = "Copied to clipboard"
        RequiredFields = "Required fields"
        StartRequired = "Start time is required."
        EndRequired = "End time is required."
        FormatRequired = "HH:mm format required"
        InvalidStart = "Invalid format. Valid example: 08:30."
        InvalidEnd = "Invalid format. Valid example: 17:15."
        Error = "Error"
        RowsToFixFormat = "{0} row(s) to fix"
        LanguageFrench = "Français"
        LanguageEnglish = "English"
    }
}

function Get-Text {
    param([string]$Key)

    return $script:Translations[$script:CurrentLanguage][$Key]
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Worktime calculator"
        Height="520"
        Width="760"
        MinHeight="420"
        MinWidth="700"
        FontFamily="Segoe UI"
        Background="#F3F2F1"
        WindowStartupLocation="CenterScreen">
    <Window.Resources>
        <SolidColorBrush x:Key="OfficeBlueBrush" Color="#0078D4"/>
        <SolidColorBrush x:Key="OfficeBlueHoverBrush" Color="#106EBE"/>
        <SolidColorBrush x:Key="OfficeBorderBrush" Color="#D2D0CE"/>
        <SolidColorBrush x:Key="OfficeTextBrush" Color="#323130"/>
        <SolidColorBrush x:Key="OfficeMutedTextBrush" Color="#605E5C"/>
        <SolidColorBrush x:Key="OfficeErrorBrush" Color="#A4262C"/>

        <Style x:Key="OfficeButtonStyle" TargetType="Button">
            <Setter Property="Background" Value="{StaticResource OfficeBlueBrush}"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="{StaticResource OfficeBlueBrush}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="4">
                            <ContentPresenter HorizontalAlignment="Center"
                                              VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="{StaticResource OfficeBlueHoverBrush}"/>
                                <Setter Property="BorderBrush" Value="{StaticResource OfficeBlueHoverBrush}"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#005A9E"/>
                                <Setter Property="BorderBrush" Value="#005A9E"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Opacity" Value="0.55"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="OfficeSecondaryButtonStyle" BasedOn="{StaticResource OfficeButtonStyle}" TargetType="Button">
            <Setter Property="Background" Value="White"/>
            <Setter Property="Foreground" Value="{StaticResource OfficeTextBrush}"/>
            <Setter Property="BorderBrush" Value="{StaticResource OfficeBorderBrush}"/>
        </Style>

        <Style x:Key="OfficeTextBoxStyle" TargetType="TextBox">
            <Setter Property="Background" Value="White"/>
            <Setter Property="BorderBrush" Value="{StaticResource OfficeBorderBrush}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="8,3"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
        </Style>
    </Window.Resources>

    <Grid Margin="16">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <Border Grid.Row="0" Background="White" BorderBrush="{StaticResource OfficeBorderBrush}" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
            <StackPanel>
                <TextBlock Name="LblHeaderTitle" Text="Calcul du temps de travail" FontSize="22" FontWeight="SemiBold" Foreground="{StaticResource OfficeTextBrush}" Margin="0,0,0,4"/>
                <TextBlock Name="LblHeaderDescription" Foreground="{StaticResource OfficeMutedTextBrush}" Text="Saisissez les heures au format HH:mm. Le total se met à jour automatiquement." Margin="0,0,0,12"/>
                <StackPanel Orientation="Horizontal">
                    <Button Name="BtnAjouter" Content="+ Ajouter une ligne" Width="150" Height="34" Margin="0,0,10,0" Style="{StaticResource OfficeButtonStyle}"/>
                    <Button Name="BtnCalculer" Content="Recalculer" Width="110" Height="34" Margin="0,0,10,0" Style="{StaticResource OfficeSecondaryButtonStyle}"/>
                    <Button Name="BtnExportCsv" Content="Export CSV" Width="110" Height="34" Margin="0,0,10,0" Style="{StaticResource OfficeSecondaryButtonStyle}"/>
                    <Button Name="BtnCopyClipboard" Content="Copy to clipboard" Width="110" Height="34" Margin="0,0,10,0" Style="{StaticResource OfficeSecondaryButtonStyle}"/>
                    <TextBlock Name="LblLanguage" Text="Langue :" VerticalAlignment="Center" Margin="6,0,6,0" Foreground="{StaticResource OfficeMutedTextBrush}"/>
                    <ComboBox Name="CmbLanguage" Width="110" Height="34" VerticalContentAlignment="Center"/>
                </StackPanel>
            </StackPanel>
        </Border>

        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" Background="Transparent">
            <StackPanel Name="PanelLignes"/>
        </ScrollViewer>

        <Border Grid.Row="2" Background="White" BorderThickness="1" BorderBrush="{StaticResource OfficeBorderBrush}" CornerRadius="6" Padding="14" Margin="0,12,0,0">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <TextBlock Grid.Column="0" Name="LblTotal" Text="Total : " FontSize="20" FontWeight="SemiBold" Foreground="{StaticResource OfficeTextBrush}"/>
                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                    <TextBlock Name="TxtTotal" Text="00:00" FontSize="20" FontWeight="SemiBold" Foreground="{StaticResource OfficeBlueBrush}"/>
                    <TextBlock Text=" (" FontSize="20" FontWeight="SemiBold" Foreground="{StaticResource OfficeMutedTextBrush}"/>
                    <TextBlock Name="TxtTotalDecimal" Text="0.00 h" FontSize="20" FontWeight="SemiBold" Foreground="{StaticResource OfficeMutedTextBrush}"/>
                    <TextBlock Text=")" FontSize="20" FontWeight="SemiBold" Foreground="{StaticResource OfficeMutedTextBrush}"/>
                </StackPanel>
                <TextBlock Grid.Column="2" Name="TxtValidationGlobale" HorizontalAlignment="Right" VerticalAlignment="Center" Foreground="{StaticResource OfficeErrorBrush}"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$btnAjouter = $window.FindName("BtnAjouter")
$btnCalculer = $window.FindName("BtnCalculer")
$btnExportCsv = $window.FindName("BtnExportCsv")
$btnCopyClipboard = $window.FindName("BtnCopyClipboard")
$cmbLanguage = $window.FindName("CmbLanguage")
$lblHeaderTitle = $window.FindName("LblHeaderTitle")
$lblHeaderDescription = $window.FindName("LblHeaderDescription")
$lblLanguage = $window.FindName("LblLanguage")
$lblTotal = $window.FindName("LblTotal")
$panelLignes = $window.FindName("PanelLignes")
$txtTotal = $window.FindName("TxtTotal")
$txtTotalDecimal = $window.FindName("TxtTotalDecimal")
$txtValidationGlobale = $window.FindName("TxtValidationGlobale")

function Get-WindowResource {
    param([string]$Name)

    return $window.Resources[$Name]
}

function Set-LocalizedText {
    $window.Title = Get-Text -Key "WindowTitle"
    $lblHeaderTitle.Text = Get-Text -Key "HeaderTitle"
    $lblHeaderDescription.Text = Get-Text -Key "HeaderDescription"
    $btnAjouter.Content = Get-Text -Key "AddRow"
    $btnCalculer.Content = Get-Text -Key "Recalculate"
    $btnExportCsv.Content = Get-Text -Key "ExportCsv"
    $btnCopyClipboard.Content = Get-Text -Key "CopyClipboard"
    $lblLanguage.Text = Get-Text -Key "Language"
    $lblTotal.Text = Get-Text -Key "TotalLabel"

    foreach ($ligne in $panelLignes.Children) {
        $controls = $ligne.Tag
        $controls.LabelDebut.Text = Get-Text -Key "StartLabel"
        $controls.LabelFin.Text = Get-Text -Key "EndLabel"
        $controls.LabelDuree.Text = Get-Text -Key "DurationLabel"
        $controls.BtnSupprimer.Content = Get-Text -Key "Delete"
    }
}

function Update-LanguagePicker {
    $cmbLanguage.Items.Clear()
    foreach ($languageCode in $script:SupportedLanguages) {
        $item = New-Object System.Windows.Controls.ComboBoxItem
        $item.Tag = $languageCode
        if ($languageCode -eq "fr") {
            $item.Content = Get-Text -Key "LanguageFrench"
        } else {
            $item.Content = Get-Text -Key "LanguageEnglish"
        }
        $cmbLanguage.Items.Add($item) | Out-Null
        if ($languageCode -eq $script:CurrentLanguage) {
            $cmbLanguage.SelectedItem = $item
        }
    }
}

function New-TimeTextBox {
    param([string]$Text = "")

    $textBox = New-Object System.Windows.Controls.TextBox
    $textBox.Width = 80
    $textBox.Height = 32
    $textBox.Margin = "5"
    $textBox.Text = $Text
    $textBox.ToolTip = (Get-Text -Key "TimeFormatTooltip")
    $textBox.Style = Get-WindowResource -Name "OfficeTextBoxStyle"
    return $textBox
}

function Convert-ToTimeSpan {
    param([string]$Value)

    $parsedDate = [datetime]::MinValue
    if ([datetime]::TryParseExact(
        $Value,
        "HH:mm",
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::None,
        [ref]$parsedDate
    )) {
        return $parsedDate.TimeOfDay
    }

    return $null
}

function Format-TimeSpan {
    param([TimeSpan]$TimeSpan)

    $totalHours = [math]::Floor($TimeSpan.TotalHours)
    $minutes = $TimeSpan.Minutes
    return "{0:00}:{1:00}" -f $totalHours, $minutes
}

function Format-TimeSpanDecimal {
    param([TimeSpan]$TimeSpan)

    return [string]::Format([System.Globalization.CultureInfo]::InvariantCulture, "{0:0.00} h", $TimeSpan.TotalHours)
}

function Set-FieldValidationState {
    param(
        [System.Windows.Controls.TextBox]$TextBox,
        [bool]$IsValid,
        [string]$Message = ""
    )

    if ($IsValid) {
        $TextBox.ClearValue([System.Windows.Controls.Control]::BorderBrushProperty)
        $TextBox.ClearValue([System.Windows.Controls.Control]::BorderThicknessProperty)
        $TextBox.ToolTip = (Get-Text -Key "TimeFormatTooltip")
        return
    }

    $TextBox.BorderBrush = Get-WindowResource -Name "OfficeErrorBrush"
    $TextBox.BorderThickness = "2"
    $TextBox.ToolTip = $Message
}

function Add-Ligne {
    param(
        [string]$Debut = "",
        [string]$Fin = ""
    )

    $border = New-Object System.Windows.Controls.Border
    $border.Background = "White"
    $border.BorderBrush = Get-WindowResource -Name "OfficeBorderBrush"
    $border.BorderThickness = "1"
    $border.CornerRadius = "6"
    $border.Padding = "10"
    $border.Margin = "0,0,0,8"

    $grid = New-Object System.Windows.Controls.Grid

    1..8 | ForEach-Object {
        $col = New-Object System.Windows.Controls.ColumnDefinition
        if ($_ -eq 8) { $col.Width = "*" } else { $col.Width = "Auto" }
        $grid.ColumnDefinitions.Add($col)
    }

    $lblDebut = New-Object System.Windows.Controls.TextBlock
    $lblDebut.Text = Get-Text -Key "StartLabel"
    $lblDebut.VerticalAlignment = "Center"
    $lblDebut.Margin = "5"
    $lblDebut.Foreground = Get-WindowResource -Name "OfficeTextBrush"

    $txtDebut = New-TimeTextBox -Text $Debut

    $lblFin = New-Object System.Windows.Controls.TextBlock
    $lblFin.Text = Get-Text -Key "EndLabel"
    $lblFin.VerticalAlignment = "Center"
    $lblFin.Margin = "5"
    $lblFin.Foreground = Get-WindowResource -Name "OfficeTextBrush"

    $txtFin = New-TimeTextBox -Text $Fin

    $lblDuree = New-Object System.Windows.Controls.TextBlock
    $lblDuree.Text = Get-Text -Key "DurationLabel"
    $lblDuree.VerticalAlignment = "Center"
    $lblDuree.Margin = "5"
    $lblDuree.Foreground = Get-WindowResource -Name "OfficeTextBrush"

    $txtDuree = New-Object System.Windows.Controls.TextBlock
    $txtDuree.Text = "00:00"
    $txtDuree.VerticalAlignment = "Center"
    $txtDuree.Margin = "5"
    $txtDuree.FontWeight = "SemiBold"
    $txtDuree.Foreground = Get-WindowResource -Name "OfficeBlueBrush"

    $txtErreur = New-Object System.Windows.Controls.TextBlock
    $txtErreur.VerticalAlignment = "Center"
    $txtErreur.Margin = "5"
    $txtErreur.Foreground = Get-WindowResource -Name "OfficeErrorBrush"

    $btnSupprimer = New-Object System.Windows.Controls.Button
    $btnSupprimer.Content = Get-Text -Key "Delete"
    $btnSupprimer.Width = 90
    $btnSupprimer.Height = 32
    $btnSupprimer.Margin = "5"
    $btnSupprimer.Style = Get-WindowResource -Name "OfficeSecondaryButtonStyle"

    [System.Windows.Controls.Grid]::SetColumn($lblDebut, 0)
    [System.Windows.Controls.Grid]::SetColumn($txtDebut, 1)
    [System.Windows.Controls.Grid]::SetColumn($lblFin, 2)
    [System.Windows.Controls.Grid]::SetColumn($txtFin, 3)
    [System.Windows.Controls.Grid]::SetColumn($lblDuree, 4)
    [System.Windows.Controls.Grid]::SetColumn($txtDuree, 5)
    [System.Windows.Controls.Grid]::SetColumn($txtErreur, 6)
    [System.Windows.Controls.Grid]::SetColumn($btnSupprimer, 7)

    $grid.Children.Add($lblDebut) | Out-Null
    $grid.Children.Add($txtDebut) | Out-Null
    $grid.Children.Add($lblFin) | Out-Null
    $grid.Children.Add($txtFin) | Out-Null
    $grid.Children.Add($lblDuree) | Out-Null
    $grid.Children.Add($txtDuree) | Out-Null
    $grid.Children.Add($txtErreur) | Out-Null
    $grid.Children.Add($btnSupprimer) | Out-Null

    $border.Child = $grid
    $border.Tag = @{
        Debut = $txtDebut
        Fin = $txtFin
        Duree = $txtDuree
        Erreur = $txtErreur
        LabelDebut = $lblDebut
        LabelFin = $lblFin
        LabelDuree = $lblDuree
        BtnSupprimer = $btnSupprimer
    }

    $txtDebut.Add_TextChanged({ Calculer-Total })
    $txtFin.Add_TextChanged({ Calculer-Total })

    $btnSupprimer.Add_Click({
        param($sender, $eventArgs)

        $ligneASupprimer = $sender.Parent.Parent
        $panelLignes.Children.Remove($ligneASupprimer)
        Calculer-Total
    })

    $panelLignes.Children.Add($border) | Out-Null
    Calculer-Total
}

function Get-WorktimeRows {
    $rows = @()

    foreach ($ligne in $panelLignes.Children) {
        $controls = $ligne.Tag
        $debutText = $controls.Debut.Text.Trim()
        $finText = $controls.Fin.Text.Trim()
        $dureeText = $controls.Duree.Text
        $erreurText = $controls.Erreur.Text

        $rows += [pscustomobject]@{
            Debut = $debutText
            Fin = $finText
            Duree = $dureeText
            Erreur = $erreurText
        }
    }

    return $rows
}

function ConvertTo-CsvText {
    Calculer-Total

    $rows = @(Get-WorktimeRows)
    $csvLines = @(Get-Text -Key "CsvHeader")

    foreach ($row in $rows) {
        $values = @($row.Debut, $row.Fin, $row.Duree, $row.Erreur) | ForEach-Object {
            $value = [string]$_
            '"' + $value.Replace('"', '""') + '"'
        }
        $csvLines += ($values -join ";")
    }

    $csvLines += ""
    $csvLines += ('"{0}";"";"{1}";"{2}"' -f (Get-Text -Key "CsvTotal"), $txtTotal.Text, $txtValidationGlobale.Text)
    $csvLines += ('"{0}";"";"{1}";""' -f (Get-Text -Key "CsvTotalDecimal"), $txtTotalDecimal.Text)

    return ($csvLines -join [Environment]::NewLine)
}

function Export-WorktimeCsv {
    $saveFileDialog = New-Object Microsoft.Win32.SaveFileDialog
    $saveFileDialog.Filter = Get-Text -Key "CsvFilter"
    $saveFileDialog.FileName = Get-Text -Key "CsvFileName"
    $saveFileDialog.DefaultExt = ".csv"

    if ($saveFileDialog.ShowDialog($window) -eq $true) {
        [System.IO.File]::WriteAllText($saveFileDialog.FileName, (ConvertTo-CsvText), [System.Text.Encoding]::UTF8)
        $txtValidationGlobale.Text = Get-Text -Key "CsvExported"
    }
}

function Copy-WorktimeToClipboard {
    [System.Windows.Clipboard]::SetText((ConvertTo-CsvText))
    $txtValidationGlobale.Text = Get-Text -Key "Copied"
}

function Calculer-Total {
    $total = [TimeSpan]::Zero
    $nombreErreurs = 0

    foreach ($ligne in $panelLignes.Children) {
        $controls = $ligne.Tag
        $debutTextBox = $controls.Debut
        $finTextBox = $controls.Fin
        $dureeTextBlock = $controls.Duree
        $erreurTextBlock = $controls.Erreur

        $debutText = $debutTextBox.Text.Trim()
        $finText = $finTextBox.Text.Trim()
        $debut = Convert-ToTimeSpan -Value $debutText
        $fin = Convert-ToTimeSpan -Value $finText

        Set-FieldValidationState -TextBox $debutTextBox -IsValid $true
        Set-FieldValidationState -TextBox $finTextBox -IsValid $true
        $erreurTextBlock.Text = ""

        if ([string]::IsNullOrWhiteSpace($debutText) -or [string]::IsNullOrWhiteSpace($finText)) {
            $dureeTextBlock.Text = "00:00"
            $dureeTextBlock.Foreground = Get-WindowResource -Name "OfficeMutedTextBrush"
            $erreurTextBlock.Text = Get-Text -Key "RequiredFields"
            if ([string]::IsNullOrWhiteSpace($debutText)) {
                Set-FieldValidationState -TextBox $debutTextBox -IsValid $false -Message (Get-Text -Key "StartRequired")
            }
            if ([string]::IsNullOrWhiteSpace($finText)) {
                Set-FieldValidationState -TextBox $finTextBox -IsValid $false -Message (Get-Text -Key "EndRequired")
            }
            $nombreErreurs++
            continue
        }

        if ($null -eq $debut -or $null -eq $fin) {
            $dureeTextBlock.Text = Get-Text -Key "Error"
            $dureeTextBlock.Foreground = Get-WindowResource -Name "OfficeErrorBrush"
            $erreurTextBlock.Text = Get-Text -Key "FormatRequired"
            if ($null -eq $debut) {
                Set-FieldValidationState -TextBox $debutTextBox -IsValid $false -Message (Get-Text -Key "InvalidStart")
            }
            if ($null -eq $fin) {
                Set-FieldValidationState -TextBox $finTextBox -IsValid $false -Message (Get-Text -Key "InvalidEnd")
            }
            $nombreErreurs++
            continue
        }

        if ($fin -lt $debut) {
            $fin = $fin.Add([TimeSpan]::FromDays(1))
        }

        $duree = $fin - $debut
        $total = $total + $duree
        $dureeTextBlock.Text = Format-TimeSpan -TimeSpan $duree
        $dureeTextBlock.Foreground = Get-WindowResource -Name "OfficeBlueBrush"
    }

    $txtTotal.Text = Format-TimeSpan -TimeSpan $total
    $txtTotalDecimal.Text = Format-TimeSpanDecimal -TimeSpan $total
    if ($nombreErreurs -gt 0) {
        $txtValidationGlobale.Text = [string]::Format((Get-Text -Key "RowsToFixFormat"), $nombreErreurs)
    } else {
        $txtValidationGlobale.Text = ""
    }
}

$cmbLanguage.Add_SelectionChanged({
    if ($null -eq $cmbLanguage.SelectedItem) { return }

    $script:CurrentLanguage = [string]$cmbLanguage.SelectedItem.Tag
    Set-LocalizedText
    Calculer-Total
})

Set-LocalizedText
Update-LanguagePicker

$btnAjouter.Add_Click({ Add-Ligne })
$btnCalculer.Add_Click({ Calculer-Total })
$btnExportCsv.Add_Click({ Export-WorktimeCsv })
$btnCopyClipboard.Add_Click({ Copy-WorktimeToClipboard })

Add-Ligne -Debut "08:00" -Fin "12:00"
Add-Ligne -Debut "13:00" -Fin "17:00"

$window.ShowDialog() | Out-Null
