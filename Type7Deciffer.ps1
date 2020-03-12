Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,124'
$Form.text                       = "SERF Cisco Type 7 Deciffer"
$Form.TopMost                    = $false

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Entrer le hash Cisco Type 7 à déchiffrer"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(9,10)
$Label1.Font                     = 'Microsoft Sans Serif,10'

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 382
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(7,35)
$TextBox1.Font                   = 'Microsoft Sans Serif,10'


$TextBox2                        = New-Object system.Windows.Forms.TextBox
$TextBox2.multiline              = $false
$TextBox2.width                  = 382
$TextBox2.height                 = 20
$TextBox2.location               = New-Object System.Drawing.Point(7,60)
$TextBox2.Font                   = 'Microsoft Sans Serif,10'
$TextBox2.Visible                = $False

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Déchiffrer "
$Button1.width                   = 90
$Button1.height                  = 30
$Button1.location                = New-Object System.Drawing.Point(160,72)
$Button1.Font                    = 'Microsoft Sans Serif,10'

$Button2                         = New-Object system.Windows.Forms.Button
$Button2.text                    = "Réinitaliser"
$Button2.width                   = 90
$Button2.height                  = 30
$Button2.location                = New-Object System.Drawing.Point(160,73)
$Button2.Font                    = 'Microsoft Sans Serif,10'
$Button2.Visible                 = $False

$Form.controls.AddRange(@($Label1,$TextBox1,$TextBox2,$Button1,$Button2))

function Unprotect-CiscoPassword7 {

    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # Encrypted password
        [Parameter(Mandatory=$true,
                    ValueFromPipeline=$true,
                    Position=0)]
        [ValidateScript({
                # Check length, starting pattern, and split out entire config line (if necessary).
                if ($_ -match 'password 7')
                {
                    $_ = (-split $_)[-1]
                }

                ($_.Length % 2 -eq 0) -and ($_ -match '^[0-9][0-9]') -and (([int]$_.Substring(0, 2)) -le 15)
            })]
        [string]$Password7Text
    )


    Begin
    {   
        # Same decryption key for everyone
        $key = "dsfd;kfoA,.iyewrkldJKDHSUBsgvca69834ncxv9873254k;fg87"
    }
    
    Process
    {
        # Handle if the input is just the password, or the full config line
        if ($Password7Text -match 'password 7')
        {
            $Password7Text = (-split $Password7Text)[-1]
        }

        # First two characters' value is the offset into the key where the decryption starts.
        $seed = [int]$Password7Text.substring(0, 2)

        # Take two characters at a time from the rest of the string
        # convert them from hex to decimal, and XOR with the next key position
        # (wrapping around the key if needed)
        # convert the resulting values to characters
        $plainTextBytes = [regex]::Matches($Password7Text.SubString(2), '..').Value | 
            ForEach-Object { 
    
                [char]([convert]::ToInt32($_, 16) -bxor $key[$seed++])
                $seed = $seed % $key.Length
        
            }

        -join $plainTextBytes    
    }

}


$Button1.Add_Click({

    
    if (!$TextBox1.Text){
    $TextBox1.Text = "J'ai faim, donnez - moi un Hash à manger !"
    }

    else {

      try {
    $Button1.location = New-Object System.Drawing.Point(110,100)
    $result = Unprotect-CiscoPassword7 $TextBox1.Text
    $test = $true

    if ($test = $true) {
    $TextBox2.Visible = $True
    $TextBox2.Text = $result
    $Button2.Visible = $True
    $Button2.location = New-Object System.Drawing.Point(210,100)
    $Form.ClientSize  = '400,150'
    
                        }
    

          }

    catch {

    $TextBox1.Text = "Le Hash saisi est invalide ! "
    $Button1.location = New-Object System.Drawing.Point(160,72)
    $TextBox2.Visible = $False
    $Button2.Visible = $False
    $Form.ClientSize = '400,124'



          }
       
 }})

 $Button2.Add_Click({

    $TextBox2.Visible = $False
    $Button2.Visible = $False
    $Form.ClientSize = '400,124'
    $Button1.location = New-Object System.Drawing.Point(160,72)
    $TextBox1.Text = $null



    })


$Form.ShowDialog()