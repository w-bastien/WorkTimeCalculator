Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Calcul du temps de travail"
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
                <TextBlock Text="Calcul du temps de travail" FontSize="22" FontWeight="SemiBold" Foreground="{StaticResource OfficeTextBrush}" Margin="0,0,0,4"/>
                <TextBlock Foreground="{StaticResource OfficeMutedTextBrush}" Text="Saisissez les heures au format HH:mm. Le total se met à jour automatiquement." Margin="0,0,0,12"/>
                <StackPanel Orientation="Horizontal">
                    <Button Name="BtnAjouter" Content="+ Ajouter une ligne" Width="150" Height="34" Margin="0,0,10,0" Style="{StaticResource OfficeButtonStyle}"/>
                    <Button Name="BtnCalculer" Content="Recalculer" Width="110" Height="34" Style="{StaticResource OfficeSecondaryButtonStyle}"/>
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
                <TextBlock Grid.Column="0" Text="Total : " FontSize="20" FontWeight="SemiBold" Foreground="{StaticResource OfficeTextBrush}"/>
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
$panelLignes = $window.FindName("PanelLignes")
$txtTotal = $window.FindName("TxtTotal")
$txtTotalDecimal = $window.FindName("TxtTotalDecimal")
$txtValidationGlobale = $window.FindName("TxtValidationGlobale")

function Get-WindowResource {
    param([string]$Name)

    return $window.Resources[$Name]
}

function New-TimeTextBox {
    param([string]$Text = "")

    $textBox = New-Object System.Windows.Controls.TextBox
    $textBox.Width = 80
    $textBox.Height = 32
    $textBox.Margin = "5"
    $textBox.Text = $Text
    $textBox.ToolTip = "Format attendu : HH:mm, exemple 08:30"
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
        $TextBox.ToolTip = "Format attendu : HH:mm, exemple 08:30"
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
    $lblDebut.Text = "Début :"
    $lblDebut.VerticalAlignment = "Center"
    $lblDebut.Margin = "5"
    $lblDebut.Foreground = Get-WindowResource -Name "OfficeTextBrush"

    $txtDebut = New-TimeTextBox -Text $Debut

    $lblFin = New-Object System.Windows.Controls.TextBlock
    $lblFin.Text = "Fin :"
    $lblFin.VerticalAlignment = "Center"
    $lblFin.Margin = "5"
    $lblFin.Foreground = Get-WindowResource -Name "OfficeTextBrush"

    $txtFin = New-TimeTextBox -Text $Fin

    $lblDuree = New-Object System.Windows.Controls.TextBlock
    $lblDuree.Text = "Durée :"
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
    $btnSupprimer.Content = "Supprimer"
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
            $erreurTextBlock.Text = "Champs obligatoires"
            if ([string]::IsNullOrWhiteSpace($debutText)) {
                Set-FieldValidationState -TextBox $debutTextBox -IsValid $false -Message "L'heure de début est obligatoire."
            }
            if ([string]::IsNullOrWhiteSpace($finText)) {
                Set-FieldValidationState -TextBox $finTextBox -IsValid $false -Message "L'heure de fin est obligatoire."
            }
            $nombreErreurs++
            continue
        }

        if ($null -eq $debut -or $null -eq $fin) {
            $dureeTextBlock.Text = "Erreur"
            $dureeTextBlock.Foreground = Get-WindowResource -Name "OfficeErrorBrush"
            $erreurTextBlock.Text = "Format HH:mm requis"
            if ($null -eq $debut) {
                Set-FieldValidationState -TextBox $debutTextBox -IsValid $false -Message "Format invalide. Exemple valide : 08:30."
            }
            if ($null -eq $fin) {
                Set-FieldValidationState -TextBox $finTextBox -IsValid $false -Message "Format invalide. Exemple valide : 17:15."
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
        $txtValidationGlobale.Text = "$nombreErreurs ligne(s) à corriger"
    } else {
        $txtValidationGlobale.Text = ""
    }
}

$btnAjouter.Add_Click({ Add-Ligne })
$btnCalculer.Add_Click({ Calculer-Total })

Add-Ligne -Debut "08:00" -Fin "12:00"
Add-Ligne -Debut "13:00" -Fin "17:00"

$window.ShowDialog() | Out-Null
