# Import necessary assembly for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Global variable to store status of IPs
$global:statusList = @{}

# Function to create the GUI window
function Create-Gui {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Corporate LAN Scanner by IT Support'
    $form.Size = New-Object System.Drawing.Size(600, 400)
    $form.StartPosition = 'CenterScreen'

    # Combine Program Name and Subtitle into one label with special formatting
    $combinedTitleText = 'DDI Downtime Host Checking'

    # Create the combined title label (program name + subtitle)
    $combinedTitleLabel = New-Object System.Windows.Forms.Label
    $combinedTitleLabel.Text = $combinedTitleText
    $combinedTitleLabel.Font = New-Object System.Drawing.Font('Comic Sans MS', 18, [System.Drawing.FontStyle]::Bold)  # Comic Sans MS with reduced font size
    $combinedTitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 51, 102)  # Darker Blue (RGB: 0, 51, 102)
    $combinedTitleLabel.AutoSize = $true
    $combinedTitleLabel.TextAlign = 'MiddleCenter'

    # Calculate the maximum width the label can have based on the form width and dynamically resize the label
    $form.Controls.Add($combinedTitleLabel)
    
    # Adjust the location and size of the title label
    $combinedTitleLabel.Width = $form.ClientSize.Width * 0.85  # Limit width to 85% of form size
    $combinedTitleLabel.Location = New-Object System.Drawing.Point([math]::Floor(($form.ClientSize.Width - $combinedTitleLabel.Width) / 2), 20)

    # Label for instructions
    $label1 = New-Object System.Windows.Forms.Label
    $label1.Text = 'Enter Starting IP and Ending IP:'
    $label1.Location = New-Object System.Drawing.Point(20, 100)
    $label1.Size = New-Object System.Drawing.Size(280, 20)
    $form.Controls.Add($label1)
    
    # Textbox for user to enter Starting IP
    $textboxStart = New-Object System.Windows.Forms.TextBox
    $textboxStart.Location = New-Object System.Drawing.Point(20, 130)
    $textboxStart.Size = New-Object System.Drawing.Size(240, 20)
    $form.Controls.Add($textboxStart)
    
    # Label 'to' between the Start and End IP fields
    $labelTo = New-Object System.Windows.Forms.Label
    $labelTo.Text = 'to'
    $labelTo.Location = New-Object System.Drawing.Point(270, 130)
    $labelTo.Size = New-Object System.Drawing.Size(20, 20)
    $form.Controls.Add($labelTo)

    # Textbox for user to enter Ending IP
    $textboxEnd = New-Object System.Windows.Forms.TextBox
    $textboxEnd.Location = New-Object System.Drawing.Point(300, 130)
    $textboxEnd.Size = New-Object System.Drawing.Size(240, 20)
    $form.Controls.Add($textboxEnd)
    
    # Button to start scanning
    $scanButton = New-Object System.Windows.Forms.Button
    $scanButton.Text = 'Start Scanning'
    $scanButton.Location = New-Object System.Drawing.Point(20, 160)
    $scanButton.Size = New-Object System.Drawing.Size(100, 30)
    $form.Controls.Add($scanButton)
    
    # ListBox to show the results
    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(20, 200)
    $listBox.Size = New-Object System.Drawing.Size(540, 160)
    $form.Controls.Add($listBox)

    # Timer object to perform periodic scanning
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 2000  # Check every 2 seconds

    # Button to start scanning
    $scanButton.Add_Click({
        $ipStart = $textboxStart.Text
        $ipEnd = $textboxEnd.Text
        
        # Validate the IP range format
        if (Validate-IP $ipStart -and Validate-IP $ipEnd) {
            $listBox.Items.Clear()
            $global:statusList.Clear()
            $ipList = Get-IPRange $ipStart $ipEnd
            # Add IPs to ListBox and initialize their status
            foreach ($ip in $ipList) {
                $listBox.Items.Add("$ip - Checking...")
                $global:statusList[$ip] = "Checking..."
            }

            # Start periodic scan
            $timer.Add_Tick({
                Update-IPStatuses $ipList $listBox
            })
            $timer.Start()
        } else {
            [System.Windows.Forms.MessageBox]::Show('Please enter valid IP addresses (e.g., 101.188.200.0)', 'Invalid IP Address', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })

    # Show the form
    $form.ShowDialog()
}

# Function to validate IP address format
function Validate-IP {
    param ([string]$ipAddress)
    
    # Ensure IP address format is valid (e.g., 101.188.200.0)
    return $ipAddress -match '^\d{1,3}(\.\d{1,3}){3}$' -and ($ipAddress.Split('.') | ForEach-Object { [int]$_ -ge 0 -and [int]$_ -le 255 }) -join '' -ne ''
}

# Function to generate the list of IPs in the range
function Get-IPRange {
    param([string]$ipStart, [string]$ipEnd)

    # Convert start and end IPs to integers
    $startInt = [BitConverter]::ToUInt32([IPAddress]::Parse($ipStart).GetAddressBytes(), 0)
    $endInt = [BitConverter]::ToUInt32([IPAddress]::Parse($ipEnd).GetAddressBytes(), 0)

    # Generate the list of IP addresses between start and end IP
    $ipList = @()
    for ($ip = $startInt; $ip -le $endInt; $ip++) {
        $ipAddress = [System.Net.IPAddress]::new($ip)
        $ipList += $ipAddress.ToString()
    }
    return $ipList
}

# Function to check the status of each IP in real-time
function Update-IPStatuses {
    param (
        [array]$ipList,
        [System.Windows.Forms.ListBox]$listBox
    )

    foreach ($ip in $ipList) {
        # Ping the IP and get status
        $status = Test-Connection -ComputerName $ip -Count 1 -Quiet
        $statusText = if ($status) { "Connected" } else { "Disconnected" }

        # Update the status if changed
        if ($global:statusList[$ip] -ne $statusText) {
            $global:statusList[$ip] = $statusText
            # Safely update the ListBox with the new status
            $sync = [System.Windows.Forms.Control]::FromHandle($listBox.Handle)
            $sync.Invoke([Action]{
                for ($i = 0; $i -lt $listBox.Items.Count; $i++) {
                    if ($listBox.Items[$i].ToString().StartsWith($ip)) {
                        $listBox.Items[$i] = "$ip - $statusText"
                        break
                    }
                }
            })
        }
    }
}

# Call the function to create the GUI
Create-Gui
