Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Temps de travail" Height="420" Width="560"
        WindowStartupLocation="CenterScreen" Background="#F3F2F1">
    <Window.Resources>
        <Style x:Key="OfficeSecondaryButtonStyle" TargetType="Button">
            <Setter Property="Margin" Value="0,0,8,0" />
            <Setter Property="Padding" Value="14,8" />
            <Setter Property="MinWidth" Value="92" />
            <Setter Property="Background" Value="#FFFFFF" />
            <Setter Property="Foreground" Value="#323130" />
            <Setter Property="BorderBrush" Value="#8A8886" />
            <Setter Property="BorderThickness" Value="1" />
            <Setter Property="Cursor" Value="Hand" />
        </Style>
    </Window.Resources>
    <Grid Margin="16">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto" />
            <RowDefinition Height="*" />
            <RowDefinition Height="Auto" />
        </Grid.RowDefinitions>

        <TextBlock Grid.Row="0" Text="Saisie des plages horaires" FontSize="20" FontWeight="SemiBold" Margin="0,0,0,12" />

        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <StackPanel Name="PanelLignes" />
        </ScrollViewer>

        <DockPanel Grid.Row="2" Margin="0,12,0,0" LastChildFill="False">
            <TextBlock Name="TxtTotal" DockPanel.Dock="Right" VerticalAlignment="Center" FontSize="16" FontWeight="SemiBold" Text="Total : 00:00" />
            <StackPanel Orientation="Horizontal" DockPanel.Dock="Left">
                <Button Name="BtnAjouter" Content="Ajouter" Style="{StaticResource OfficeSecondaryButtonStyle}" />
                <Button Name="BtnCalculer" Content="Calculer" Style="{StaticResource OfficeSecondaryButtonStyle}" />
                <Button Name="BtnReinitialiser" Content="Réinitialiser" Style="{StaticResource OfficeSecondaryButtonStyle}" />
            </StackPanel>
        </DockPanel>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$panelLignes = $window.FindName("PanelLignes")
$txtTotal = $window.FindName("TxtTotal")
$btnAjouter = $window.FindName("BtnAjouter")
$btnCalculer = $window.FindName("BtnCalculer")
$btnReinitialiser = $window.FindName("BtnReinitialiser")

function Add-Ligne {
    param(
        [string] $Debut = "",
        [string] $Fin = ""
    )

    $ligne = New-Object System.Windows.Controls.StackPanel
    $ligne.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $ligne.Margin = New-Object System.Windows.Thickness -ArgumentList 0, 0, 0, 8

    $txtDebut = New-Object System.Windows.Controls.TextBox
    $txtDebut.Width = 90
    $txtDebut.Margin = New-Object System.Windows.Thickness -ArgumentList 0, 0, 8, 0
    $txtDebut.Text = $Debut

    $txtFin = New-Object System.Windows.Controls.TextBox
    $txtFin.Width = 90
    $txtFin.Margin = New-Object System.Windows.Thickness -ArgumentList 0, 0, 8, 0
    $txtFin.Text = $Fin

    $ligne.Children.Add((New-Object System.Windows.Controls.TextBlock -Property @{ Text = "Début"; VerticalAlignment = "Center"; Margin = (New-Object System.Windows.Thickness -ArgumentList 0, 0, 6, 0) })) | Out-Null
    $ligne.Children.Add($txtDebut) | Out-Null
    $ligne.Children.Add((New-Object System.Windows.Controls.TextBlock -Property @{ Text = "Fin"; VerticalAlignment = "Center"; Margin = (New-Object System.Windows.Thickness -ArgumentList 0, 0, 6, 0) })) | Out-Null
    $ligne.Children.Add($txtFin) | Out-Null

    $panelLignes.Children.Add($ligne) | Out-Null
}

function Calculer-Total {
    $total = [TimeSpan]::Zero

    foreach ($ligne in $panelLignes.Children) {
        $debut = $ligne.Children[1].Text
        $fin = $ligne.Children[3].Text

        $debutTime = [datetime]::MinValue
        $finTime = [datetime]::MinValue

        if ([datetime]::TryParseExact($debut, "HH:mm", $null, [System.Globalization.DateTimeStyles]::None, [ref]$debutTime) -and
            [datetime]::TryParseExact($fin, "HH:mm", $null, [System.Globalization.DateTimeStyles]::None, [ref]$finTime) -and
            $finTime -gt $debutTime) {
            $total = $total.Add($finTime - $debutTime)
        }
    }

    $txtTotal.Text = "Total : {0:00}:{1:00}" -f [math]::Floor($total.TotalHours), $total.Minutes
}

$btnAjouter.Add_Click({
    Add-Ligne
})

$btnCalculer.Add_Click({
    Calculer-Total
})

$btnReinitialiser.Add_Click({
    $panelLignes.Children.Clear()
    Add-Ligne -Debut "08:00" -Fin "12:00"
    Add-Ligne -Debut "13:00" -Fin "17:00"
    Calculer-Total
})

Add-Ligne -Debut "08:00" -Fin "12:00"
Add-Ligne -Debut "13:00" -Fin "17:00"
Calculer-Total

$window.ShowDialog() | Out-Null
