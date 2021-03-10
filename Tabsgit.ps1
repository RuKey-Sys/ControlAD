Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$domain_name = "CORP"  #domain name
$path_to_root = "\\dcspb\root" #Path to profile

Function Search(){
    $PC_list.Items.Clear()
    $Surname="*"+$SerachStr.Text+"*"
    $PCs = Get-ADComputer -Properties * -Filter {Description -like $Surname}|Sort-Object lastlogondate -descending|Select-Object Description,name
    Foreach ($pc in $PCs){
        $PC_list.Items.Add($pc.name+" "+$pc.Description);
    }
}
Function Property(){
    $pcname_with_username= -split $PC_list.SelectedItem
    $pcname = $pcname_with_username[0]
    $b = Get-ADComputer -Properties Name,IPV4Address,Description,LastLogonDate,DnsHostName -Filter {Name -like $pcname}| Select-Object Description,DNSHostName,IPv4Address,LastLogonDate
    $Name_result.text = $b.description
    $PC_result.text   = $b.DNSHostName
    $IP_result.text   = $b.IPv4Address
    $Date_result.text = $b.LastLogonDate
  }
Function Connecting(){
    $pcname_with_username= -split $PC_list.SelectedItem
    $pcname = $pcname_with_username[0]
    Start-Process "C:\Program Files (x86)\DameWare\DameWare NT Utilities 7.5\DWRCC.exe" -Argumentlist "-c: -h: -a:1 -m:$pcname -d:$domain_name"
}
Function ButtonFolder_Click(){
        $a = Get-ADUser -Filter {Name -like $List_Name.SelectedItem} -Properties SamAccountName, ProfilePath|Select-Object SamAccountName
        $a = $a.SamAccountName
        $dir = Get-ChildItem -Path $path_to_root -Filter "$a.*" -Recurse -Depth 1 -Directory -Name
        foreach($dira in $dir){
            $dira = "$path_to_root\"+$dira
            $dira|remove-item -Recurse -force
            [System.Windows.Forms.MessageBox]::Show("Данные удалены" , "$dira")
        }
        $Delete_form.Close()
}
Function ButtonUser_Click(){
    $a = Get-ADUser -Filter {Name -like $List_Name.SelectedItem} -Properties SamAccountName, ProfilePath|Select-Object SamAccountName
    $a = $a.SamAccountName
    remove-aduser $a -confirm:$false
    [System.Windows.Forms.MessageBox]::Show("Пользователь удален" , "$a")
}
Function ShowUsers(){
    $List_Name.Items.Clear()
    $Page2.controls.Clear()
    $Page2.controls.AddRange(@( 
        $Delete_btn,
        $List_Name,
        $Text_with_name,
        $Lastlogon_date,
        $User_btn,
        $Prop_btn,
        $Lastlogon_date_text,
        $Label4,
        $Label5,
        $Label3,
        $do,
        $date,
        $user,
        $username,
        $ButtonComp,
        $Foldersize1,
        $ShowFolder
    ))
    $num=$Text_with_name.text
    $date_with_offset= (Get-Date).AddDays(-$num)
    $date.text = $date_with_offset
    $Users = Get-ADUser -Filter 'Enabled -eq "False" -and lastlogondate -lt $date_with_offset' -Properties lastlogonDate,profilepath|Select-Object Name,LastlogonDate,Profilepath|Sort-Object name
    Foreach ($User in $Users){
        $List_Name.Items.Add($User.Name);
    }
    }
Function ShowComps(){
    $Page2.controls.Clear()
    $Page2.controls.AddRange(@($List_Name,$Text_with_name,$Lastlogon_date,$User_btn,$Prop_btn,$Lastlogon_date_text,$Label3,$LastUser,$LastUser1,$ButtonComp,$ButtonDelComp))
    $List_Name.Items.Clear()
    $num=$Text_with_name.text
    $date_with_offset= (Get-Date).AddDays(-$num)
    $date.text = $date_with_offset
    $computers = Get-ADComputer -Filter 'lastlogondate -lt $date_with_offset' -Properties ObjectClass,lastlogonDate|Sort-Object name
    Foreach ($computer in $computers){
        $List_Name.Items.Add($computer.Name);
    }
}
Function More{
    $Foldersize1.Items.Clear()
    $object=Get-ADObject -Filter {name -like $List_Name.SelectedItem}|Select-Object ObjectClass
    if($object.ObjectClass -like 'user'){
        $lastdate =  get-aduser -filter 'Name -like $List_Name.SelectedItem' -Properties lastlogondate|Select-Object lastlogondate
        $Label3.Text = $lastdate.lastlogondate
        $a = Get-ADUser -Filter {Name -like $List_Name.SelectedItem} -Properties SamAccountName, ProfilePath|Select-Object SamAccountName
        $a = $a.SamAccountName
        $dir = Get-ChildItem -Path $path_to_root -Filter "$a.*" -Recurse -Depth 1 -Directory -Name
        $Label5.Text = $dir
        Foreach ($dira in $dir){
            $FolderSizeDR = Get-ChildItem "$path_to_root\$dira" -Recurse | measure -Property length -Sum
            $Foldersize1.Items.Add("{0:N2} "-f ((($FolderSizeDR.Sum)/1024)/1024) +"Mb|||"+$dira)
        }
        $username.Text = "$a"
}        
    else{
        $num=$Text_with_name.text
        $date_with_offset= (Get-Date).AddDays(-$num)
        $a = Get-ADComputer -Filter {lastlogondate -lt $date_with_offset -and Name -like $List_Name.SelectedItem} -Properties ObjectClass,lastlogonDate,Description|select lastlogondate
        $Label3.Text = $a.lastlogondate
        $a = $a.LastlogonDate
        $created_PC = Get-ADComputer -Filter {Name -like $List_Name.SelectedItem} -Properties Description|Select-Object Description
        $LastUser1.text = $created_PC.Description
        
        
    }
    }
Function Delete(){
[System.Windows.Forms.Application]::EnableVisualStyles()

$Delete_form                     = New-Object system.Windows.Forms.Form
$Delete_form.ClientSize          = '377,115'
$Delete_form.text                = $List_Name.SelectedItem
$Delete_form.TopMost             = $false

$Lastlogon_date_text             = New-Object system.Windows.Forms.Label
$Lastlogon_date_text.AutoSize    = $true
$Lastlogon_date_text.width       = 25
$Lastlogon_date_text.height      = 10
$Lastlogon_date_text.location    = New-Object System.Drawing.Point(353,236)
$Lastlogon_date_text.Font        = 'Microsoft Sans Serif,10'

$Label5                          = New-Object system.Windows.Forms.Label
$Label5.AutoSize                 = $true
$Label5.width                    = 25
$Label5.height                   = 10
$Label5.location                 = New-Object System.Drawing.Point(284,283)
$Label5.Font                     = 'Microsoft Sans Serif,10'

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Папки"
$Button1.width                   = 140
$Button1.height                  = 30
$Button1.location                = New-Object System.Drawing.Point(25,44)
$Button1.Font                    = 'Microsoft Sans Serif,10'

$User_btn                         = New-Object system.Windows.Forms.Button
$User_btn.text                    = "Пользователь"
$User_btn.width                   = 140
$User_btn.height                  = 30
$User_btn.location                = New-Object System.Drawing.Point(207,44)
$User_btn.Font                    = 'Microsoft Sans Serif,10'

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Удаление данных"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(125,15)
$Label1.Font                     = 'Microsoft Sans Serif,10'

$Delete_form.controls.AddRange(@($Lastlogon_date_text,$Label5,$Button1,$User_btn,$Label1))

$Button1.Add_Click({ButtonFolder_Click})
$User_btn.Add_Click({ButtonUser_Click})

$Delete_form.ShowDialog()
}
Function DeletePC(){
    $a = Get-ADComputer -Filter {Name -like $List_Name.SelectedItem}
    remove-adcomputer $a.Name -confirm:$false
    [System.Windows.Forms.MessageBox]::Show("Компьютер удален" , "$a")

}
Function OpenFolder(){
    $selectedfolder = -split $Label5.Text
    foreach ($fold in $selectedfolder){
        if($Foldersize1.SelectedItem -like "*$fold"){
            $explore = $path_to_root+'\'+$fold
            explorer.exe $explore
        }
        else{
            continue
        }
    }
}
Function Ping(){
    $pcname_with_username= -split $PC_list.SelectedItem
    $pcname = $pcname_with_username[0]
    Start-Process ping $pcname, -t
}
Function Pswd(){
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $pcname_with_username= -split $PC_list.SelectedItem
    $usernameforpswd = $pcname_with_username[1,2,3] -join " "
    $a = Get-ADUser -filter {name -like $usernameforpswd} -Properties samaccountname|Select-Object samaccountname
    $samacc = $a.samaccountname

    $Change_pswd                     = New-Object system.Windows.Forms.Form
    $Change_pswd.ClientSize          = '400,144'
    $Change_pswd.text                = "$usernameforpswd"
    $Change_pswd.TopMost             = $false
    $Change_pswd.BackColor           = "#363636"
    $Change_pswd.AutoSize            = $true
    $Change_pswd.FormBorderStyle     = [System.Windows.Forms.FormBorderStyle]::FixedDialog

    $ChngPSWDstring                  = New-Object system.Windows.Forms.MaskedTextBox
    $ChngPSWDstring.PasswordChar     = '*'

    $ChngPSWDstring.text             = ""  
    $ChngPSWDstring.multiline        = $false
    $ChngPSWDstring.width            = 128
    $ChngPSWDstring.height           = 20
    $ChngPSWDstring.location         = New-Object System.Drawing.Point(182,28)
    $ChngPSWDstring.Font             = 'Microsoft Sans Serif,10'
    
    $PswdTEXT                        = New-Object system.Windows.Forms.Label
    $PswdTEXT.text                   = "Введите новый пароль:"
    $PswdTEXT.AutoSize               = $true
    $PswdTEXT.width                  = 25
    $PswdTEXT.height                 = 10
    $PswdTEXT.location               = New-Object System.Drawing.Point(25,32)
    $PswdTEXT.Font                   = 'Microsoft Sans Serif,10'
    $PswdTEXT.ForeColor              = "#ffffff"

    $Cngbtn                          = New-Object system.Windows.Forms.Button
    $Cngbtn.text                     = "Сменить"
    $Cngbtn.width                    = 120
    $Cngbtn.height                   = 40
    $Cngbtn.location                 = New-Object System.Drawing.Point(153,87)
    $Cngbtn.Font                     = 'Microsoft Sans Serif,10'
    $Cngbtn.ForeColor                = "#ffffff"

    $Textcng                          = New-Object system.Windows.Forms.Label
    $Textcng.text                     = "При входе будет предложено заменить на другой."
    $Textcng.AutoSize                 = $true
    $Textcng.width                    = 25
    $Textcng.height                   = 10
    $Textcng.location                 = New-Object System.Drawing.Point(25,62)
    $Textcng.Font                     = 'Microsoft Sans Serif,10'
    $Textcng.ForeColor                = "#ffffff"

    $Change_pswd.controls.AddRange(@($ChngPSWDstring,$PswdTEXT,$Textcng,$Cngbtn))
    $Cngbtn.add_Click({Change_Password($samacc)})
    $Change_pswd.ShowDialog()
}
Function Change_Password($samacc){ 
    $NewPasswd=ConvertFrom-SecureString $ChngPSWDstring.text
    Set-ADAccountPassword $samacc -NewPassword $NewPasswd -Reset -PassThru | Set-ADuser -ChangePasswordAtLogon $True
    [System.Windows.Forms.MessageBox]::Show("$NewPasswd Пароль","$samacc Логин")
    $Change_pswd.Close()
}
Function SoftwareList(){
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $pcname_with_username= -split $PC_list.SelectedItem
    $pcname = $pcname_with_username[0]

    $SoftwareList                    = New-Object system.Windows.Forms.Form
    $SoftwareList.ClientSize         = '400,409'
    $SoftwareList.text               = "список программ на $pcname"
    $SoftwareList.TopMost            = $false
    $SoftwareList.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog

    $softwarelist_box                = New-Object system.Windows.Forms.Listbox
    $softwarelist_box.text           = "listView"
    $softwarelist_box.width          = 387
    $softwarelist_box.height         = 351
    $softwarelist_box.location       = New-Object System.Drawing.Point(7,48)

    $LabelSoftwarelist               = New-Object system.Windows.Forms.Label
    $LabelSoftwarelist.text          = "Список установленных программ"
    $LabelSoftwarelist.AutoSize      = $true
    $LabelSoftwarelist.width         = 25
    $LabelSoftwarelist.height        = 10
    $LabelSoftwarelist.location      = New-Object System.Drawing.Point(89,16)
    $LabelSoftwarelist.Font          = 'Microsoft Sans Serif,10'

    $SoftwareList.controls.AddRange(@($softwarelist_box,$LabelSoftwarelist))
     
    $soft = Get-SystemInfo $pcname -SoftwareList -JobTimeOut 240 | foreach {$_.SoftwareList} | Where-Object {$_.AppName}|Select-Object AppName,version
    Foreach ($programm in $soft){
        $softwarelist_box.Items.Add($programm.appname+" ||| "+ $programm.version);
    }

    $SoftwareList.ShowDialog()
}
Function HardwareList(){
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $pcname_with_username = -split $PC_list.SelectedItem
    $pcname = $pcname_with_username[0]

    $HardwareList                    = New-Object system.Windows.Forms.Form
    $HardwareList.ClientSize         = '400,409'
    $HardwareList.text               = "$pcname"
    $HardwareList.TopMost            = $false
    $HardwareList.FormBorderStyle    = [System.Windows.Forms.FormBorderStyle]::FixedDialog
 
    $Hardware                        = New-Object system.Windows.Forms.RichTextbox
    $Hardware.text                   = ""
    $Hardware.width                  = 385
    $Hardware.height                 = 394
    $Hardware.location               = New-Object System.Drawing.Point(7,6)

    $a = Get-SystemInfo $pcname -Cpu -Motherboard -Memory -Properties OsVersion,OsProductKey -ProcessFor 100 -JobTimeOut 30| Out-String -Width $Hardware.Width
    $Hardware.Text += "$a"

    $HardwareList.controls.AddRange(@($Hardware))
    $HardwareList.ShowDialog()
}


$tabs = New-object System.Windows.Forms.TabControl
$tabs.ClientSize ='700,500'
$tabs.Name = "tabControl"
$tabs.TabIndex = 0

$MainForm                         = New-Object system.Windows.Forms.Form
$MainForm.ClientSize              ='700,500'
$MainForm.text                    = "ControlAD"
$MainForm.TopMost                 = $false
$MainForm.AutoSize                = $true
$MainForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$MainForm.Controls.Add($tabs)

$Page1                            = New-Object system.Windows.Forms.TabPage
$Page1.Name                       = "Page1"
$Page1.text                       = "Dameware"
$Page1.TabIndex                   = 1
$Page1.UseVisualStyleBackColor    = $False
$Page1.Controls.Add($SerachStr)
$tabs.Controls.Add($Page1)
$Page1.BackColor = "#363636"

$Page2                            = New-Object system.Windows.Forms.TabPage
$Page2.Name                       = "Page2"
$Page2.text                       = "ClearAD"
$Page2.TabIndex                   = 2
#$Page2.UseVisualStyleBackColor    = $False
$Page2.BackColor = "#363636"
$tabs.Controls.Add($Page2)

$handler_tabpage_SelectedIndexChanged = { 
    if($tabs.SelectedTab.Name -eq "Page1"){
        $Page1.Controls.Clear()
        $MainForm.Controls.Add($tabs)
        $Page1.controls.AddRange(@(
            $Mainlabel,
            $PingBtn,
            $Chngpswd,
            $SerachStr,
            $SearchBtn,
            $NameLabel,
            $PCLabel,
            $IPlabel,
            $DateLabel,
            $Name_result,
            $PC_result,
            $IP_result,
            $Date_result,
            $softwarebtn,
            $hardwarebtn,
            $PropertyBtn,
            $ConnectBtn,
            $PC_list,
            $GroupProperty
        ))
    }
    elseif($tabs.SelectedTab.Name -eq "Page2"){
        $MainForm.Controls.Add($tabs)
        $Page2.controls.AddRange(@(
            $Delete_btn,
            $List_Name,
            $Text_with_name,
            $Lastlogon_date,
            $User_btn,
            $Prop_btn,
            $ButtonComp
        ))
    }
}

$Delete_btn                       = New-Object system.Windows.Forms.Button
$Delete_btn.text                  = "Удалить"
$Delete_btn.width                 = 125
$Delete_btn.height                = 45
$Delete_btn.location              = New-Object System.Drawing.Point(283,112)
$Delete_btn.Font                  = 'Microsoft Sans Serif,10'
$Delete_btn.ForeColor             = "#ffffff"

$ButtonDelComp                    = New-Object system.Windows.Forms.Button
$ButtonDelComp.text               = "Удалить"
$ButtonDelComp.width              = 125
$ButtonDelComp.height             = 45
$ButtonDelComp.location           = New-Object System.Drawing.Point(283,112)
$ButtonDelComp.Font               = 'Microsoft Sans Serif,10'
$ButtonDelComp.ForeColor          = "#ffffff"

$User_btn                         = New-Object system.Windows.Forms.Button
$User_btn.text                    = "Пользователи"
$User_btn.width                   = 125
$User_btn.height                  = 45
$User_btn.location                = New-Object System.Drawing.Point(283,65)
$User_btn.Font                    = 'Microsoft Sans Serif,10'
$User_btn.ForeColor               = "#ffffff"


$ButtonComp                       = New-Object system.Windows.Forms.Button
$ButtonComp.text                  = "Компьютеры"
$ButtonComp.width                 = 125
$ButtonComp.height                = 45
$ButtonComp.location              = New-Object System.Drawing.Point(410,65)
$ButtonComp.Font                  = 'Microsoft Sans Serif,10'
$ButtonComp.ForeColor             = "#ffffff"

$Prop_btn                         = New-Object system.Windows.Forms.Button
$Prop_btn.text                    = "Подробнее..."
$Prop_btn.width                   = 125
$Prop_btn.height                  = 45
$Prop_btn.location                = New-Object System.Drawing.Point(283,160)
$Prop_btn.Font                    = 'Microsoft Sans Serif,10'
$Prop_btn.ForeColor               = "#ffffff"

$ShowFolder                       = New-Object system.Windows.Forms.Button
$ShowFolder.text                  = "Открыть папку"
$ShowFolder.width                 = 125
$ShowFolder.height                = 45
$ShowFolder.location              = New-Object System.Drawing.Point(535,340)
$ShowFolder.Font                  = 'Microsoft Sans Serif,10'
$ShowFolder.ForeColor             = "#ffffff"

$List_Name                        = New-Object system.Windows.Forms.ListBox
$List_Name.text                   = "listBox"
$List_Name.width                  = 236
$List_Name.height                 = 410
$List_Name.location               = New-Object System.Drawing.Point(25,50)

$Text_with_name                   = New-Object system.Windows.Forms.TextBox
$Text_with_name.multiline         = $false
$Text_with_name.text              = ""
$Text_with_name.width             = 100
$Text_with_name.height            = 20
$Text_with_name.location          = New-Object System.Drawing.Point(270,15)
$Text_with_name.Font              = 'Microsoft Sans Serif,10,style=Bold'


$Lastlogon_date                   = New-Object system.Windows.Forms.Label
$Lastlogon_date.text              = "Последний вход(кол-во дней назад):"
$Lastlogon_date.AutoSize          = $true
$Lastlogon_date.width             = 25
$Lastlogon_date.height            = 10
$Lastlogon_date.location          = New-Object System.Drawing.Point(20,20)
$Lastlogon_date.Font              = 'Microsoft Sans Serif,10'
$Lastlogon_date.ForeColor         = "#ffffff"

$Lastlogon_date_text              = New-Object system.Windows.Forms.Label
$Lastlogon_date_text.text         = "Дата последнего входа:"
$Lastlogon_date_text.AutoSize     = $true
$Lastlogon_date_text.width        = 25
$Lastlogon_date_text.height       = 10
$Lastlogon_date_text.location     = New-Object System.Drawing.Point(283,216)
$Lastlogon_date_text.Font         = 'Microsoft Sans Serif,10'
$Lastlogon_date_text.ForeColor    = "#ffffff"

$Label3                           = New-Object system.Windows.Forms.Label
$Label3.AutoSize                  = $true
$Label3.width                     = 25
$Label3.height                    = 10
$Label3.location                  = New-Object System.Drawing.Point(353,236)
$Label3.Font                      = 'Microsoft Sans Serif,10'
$Label3.ForeColor                 = "#ffffff"

$Label4                           = New-Object system.Windows.Forms.Label
$Label4.text                      = "Папки пользователя:"
$Label4.AutoSize                  = $true
$Label4.width                     = 25
$Label4.height                    = 10
$Label4.location                  = New-Object System.Drawing.Point(284,261)
$Label4.Font                      = 'Microsoft Sans Serif,10'
$Label4.ForeColor                 = "#ffffff"

$Label5                           = New-Object system.Windows.Forms.Label
$Label5.AutoSize                  = $true
$Label5.width                     = 25
$Label5.height                    = 10
$Label5.location                  = New-Object System.Drawing.Point(284,283)
$Label5.Font                      = 'Microsoft Sans Serif,10'
$Label5.ForeColor                 = "#ffffff"

$do                               = New-Object system.Windows.Forms.Label
$do.text                          = "До:"
$do.AutoSize                      = $true
$do.width                         = 25
$do.height                        = 10
$do.location                      = New-Object System.Drawing.Point(297,45)
$do.Font                          = 'Microsoft Sans Serif,10'
$do.ForeColor                     = "#ffffff"

$date                             = New-Object system.Windows.Forms.Label
$date.AutoSize                    = $true
$date.width                       = 25
$date.height                      = 10
$date.location                    = New-Object System.Drawing.Point(336,45)
$date.Font                        = 'Microsoft Sans Serif,10'
$date.ForeColor                   = "#ffffff"

$user                             = New-Object system.Windows.Forms.Label
$user.text                        = "Логин:"
$user.AutoSize                    = $true
$user.width                       = 25
$user.height                      = 10
$user.location                    = New-Object System.Drawing.Point(284,308)
$user.Font                        = 'Microsoft Sans Serif,10'
$user.ForeColor                   = "#ffffff"


$username                         = New-Object system.Windows.Forms.Label
$username.Text                    = ""
$username.AutoSize                = $true
$username.width                   = 25
$username.height                  = 10
$username.location                = New-Object System.Drawing.Point(340,308)
$username.Font                    = 'Microsoft Sans Serif,10'
$username.ForeColor               = "#ffffff"

$LastUser                         = New-Object system.Windows.Forms.Label
$LastUser.text                    = "Последний пользователь:"
$LastUser.AutoSize                = $true
$LastUser.width                   = 25
$LastUser.height                  = 10
$LastUser.location                = New-Object System.Drawing.Point(284,261)
$LastUser.Font                    = 'Microsoft Sans Serif,10'
$LastUser.ForeColor               = "#ffffff"

$LastUser1                        = New-Object system.Windows.Forms.Label
$LastUser1.text                   = ""
$LastUser1.AutoSize               = $true
$LastUser1.width                  = 25
$LastUser1.height                 = 10
$LastUser1.location               = New-Object System.Drawing.Point(284,283)
$LastUser1.Font                   = 'Microsoft Sans Serif,10'
$LastUser1.ForeColor              = "#ffffff"

$Foldersize1                      = New-Object system.Windows.Forms.ListBox
$Foldersize1.text                 = "folders"
$Foldersize1.width                = 250
$Foldersize1.height               = 100
$Foldersize1.location             = New-Object System.Drawing.Point(284,340)


$User_btn.Add_Click({ShowUsers})
$ButtonComp.Add_click({ShowComps})
$Prop_btn.Add_Click({More})
$Delete_btn.Add_Click({Delete})
$ButtonDelComp.Add_Click({DeletePC})
$ShowFolder.Add_Click({OpenFolder})

$Mainlabel                       = New-Object system.Windows.Forms.Label
$Mainlabel.text                  = "Ведите часть фамилии/имени пользователя"
$Mainlabel.AutoSize              = $true
$Mainlabel.width                 = 25
$Mainlabel.height                = 10
$Mainlabel.location              = New-Object System.Drawing.Point(25,28)
$Mainlabel.Font                  = 'Microsoft Sans Serif,10'
$Mainlabel.ForeColor             = "#ffffff"


$SerachStr                       = New-Object system.Windows.Forms.TextBox
$SerachStr.Text                  = ""
$SerachStr.multiline             = $false
$SerachStr.width                 = 373
$SerachStr.height                = 20
$SerachStr.location              = New-Object System.Drawing.Point(25,53)
$SerachStr.Font                  = 'Microsoft Sans Serif,10'


$SerachStr.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
         Search($SerachStr.Text)
    }
})


$SearchBtn                       = New-Object system.Windows.Forms.Button
$SearchBtn.text                  = "Поиск"
$SearchBtn.width                 = 90
$SearchBtn.height                = 30
$SearchBtn.location              = New-Object System.Drawing.Point(422,53)
$SearchBtn.Font                  = 'Microsoft Sans Serif,10'
$SearchBtn.ForeColor             = "#ffffff"
$SearchBtn.border

$NameLabel                       = New-Object system.Windows.Forms.Label
$NameLabel.text                  = "Имя"
$NameLabel.AutoSize              = $true
$NameLabel.width                 = 25
$NameLabel.height                = 10
$NameLabel.location              = New-Object System.Drawing.Point(34,297)
$NameLabel.Font                  = 'Microsoft Sans Serif,10'
$NameLabel.ForeColor             = "#ffffff"

$PCLabel                         = New-Object system.Windows.Forms.Label
$PCLabel.text                    = "Компьютер"
$PCLabel.AutoSize                = $true
$PCLabel.width                   = 25
$PCLabel.height                  = 10
$PCLabel.location                = New-Object System.Drawing.Point(34,322)
$PCLabel.Font                    = 'Microsoft Sans Serif,10'
$PCLabel.ForeColor               = "#ffffff"

$IPlabel                         = New-Object system.Windows.Forms.Label
$IPlabel.text                    = "IP"
$IPlabel.AutoSize                = $true
$IPlabel.width                   = 25
$IPlabel.height                  = 10
$IPlabel.location                = New-Object System.Drawing.Point(34,343)
$IPlabel.Font                    = 'Microsoft Sans Serif,10'
$IPlabel.ForeColor               = "#ffffff"

$DateLabel                       = New-Object system.Windows.Forms.Label
$DateLabel.text                  = "Дата последнего входа"
$DateLabel.AutoSize              = $true
$DateLabel.width                 = 25
$DateLabel.height                = 10
$DateLabel.location              = New-Object System.Drawing.Point(34,368)
$DateLabel.Font                  = 'Microsoft Sans Serif,10'
$DateLabel.ForeColor             = "#ffffff"

$Name_result                     = New-Object system.Windows.Forms.Label
$Name_result.text                = ""
$Name_result.AutoSize            = $true
$Name_result.width               = 25
$Name_result.height              = 10
$Name_result.location            = New-Object System.Drawing.Point(197,297)
$Name_result.Font                = 'Microsoft Sans Serif,10'
$Name_result.ForeColor           = "#ffffff"

$PC_result                       = New-Object system.Windows.Forms.Label
$PC_result.text                  = ""
$PC_result.AutoSize              = $true
$PC_result.width                 = 25
$PC_result.height                = 10
$PC_result.location              = New-Object System.Drawing.Point(197,322)
$PC_result.Font                  = 'Microsoft Sans Serif,10'
$PC_result.ForeColor             = "#ffffff"

$IP_result                       = New-Object system.Windows.Forms.Label
$IP_result.text                  = ""
$IP_result.AutoSize              = $true
$IP_result.width                 = 25
$IP_result.height                = 10
$IP_result.location              = New-Object System.Drawing.Point(197,343)
$IP_result.Font                  = 'Microsoft Sans Serif,10'
$IP_result.ForeColor             = "#ffffff"

$Date_result                     = New-Object system.Windows.Forms.Label
$Date_result.text                = ""
$Date_result.AutoSize            = $true
$Date_result.width               = 25
$Date_result.height              = 10
$Date_result.location            = New-Object System.Drawing.Point(196,368)
$Date_result.Font                = 'Microsoft Sans Serif,10'
$Date_result.ForeColor           = "#ffffff"

$PropertyBtn                     = New-Object system.Windows.Forms.Button
$PropertyBtn.text                = "Подробнее"
$PropertyBtn.width               = 90
$PropertyBtn.height              = 30
$PropertyBtn.location            = New-Object System.Drawing.Point(422,136)
$PropertyBtn.Font                = 'Microsoft Sans Serif,10'
$PropertyBtn.ForeColor           = "#ffffff"

$ConnectBtn                      = New-Object system.Windows.Forms.Button
$ConnectBtn.text                 = "Подключиться"
$ConnectBtn.width                = 90
$ConnectBtn.height               = 30
$ConnectBtn.location             = New-Object System.Drawing.Point(422,93)
$ConnectBtn.Font                 = 'Microsoft Sans Serif,8'
$ConnectBtn.ForeColor            = "#ffffff"

$PingBtn                         = New-Object system.Windows.Forms.Button
$PingBtn.text                    = "Ping"
$PingBtn.width                   = 90
$PingBtn.height                  = 30
$PingBtn.location                = New-Object System.Drawing.Point(422,179)
$PingBtn.Font                    = 'Microsoft Sans Serif,8'
$PingBtn.ForeColor               = "#ffffff"


$PC_list                         = New-Object system.Windows.Forms.ListBox
$PC_list.text                    = "listBox"
$PC_list.width                   = 374
$PC_list.height                  = 153
$PC_list.location                = New-Object System.Drawing.Point(25,93)

$GroupProperty                   = New-Object system.Windows.Forms.Groupbox
$GroupProperty.height            = 124
$GroupProperty.width             = 500
$GroupProperty.text              = "Подробности"
$GroupProperty.location          = New-Object System.Drawing.Point(17,273)
$GroupProperty.AutoSize          = $true
$GroupProperty.ForeColor         = "#ffffff"

$Chngpswd                        = New-Object system.Windows.Forms.Button
$Chngpswd.text                   = "Сменить пароль"
$Chngpswd.width                  = 90
$Chngpswd.height                 = 30
$Chngpswd.location               = New-Object System.Drawing.Point(515,53)
$Chngpswd.Font                   = 'Microsoft Sans Serif,8'
$Chngpswd.ForeColor              = "#ffffff"

$softwarebtn                     = New-Object system.Windows.Forms.Button
$softwarebtn.text                = "Список программ"
$softwarebtn.width               = 90
$softwarebtn.height              = 30
$softwarebtn.location            = New-Object System.Drawing.Point(515,136)
$softwarebtn.Font                = 'Microsoft Sans Serif,8'
$softwarebtn.ForeColor           = "#ffffff"

$hardwarebtn                     = New-Object system.Windows.Forms.Button
$hardwarebtn.text                = "что внутри"
$hardwarebtn.width               = 90
$hardwarebtn.height              = 30
$hardwarebtn.location            = New-Object System.Drawing.Point(515,179)
$hardwarebtn.Font                = 'Microsoft Sans Serif,8'
$hardwarebtn.ForeColor           = "#ffffff"

$softwarebtn.Add_click({SoftwareList})
$hardwarebtn.Add_click({HardwareList})
# $Cngbtn.add_Click({Change_Password($samacc)})
$Chngpswd.Add_click({Pswd})
$PingBtn.Add_click({Ping})
$SearchBtn.Add_click({Search})
$PropertyBtn.Add_click({Property})
$ConnectBtn.Add_click({Connecting})
$mainsize=$MainForm.ClientSize

$MainForm.ShowIcon = $false
#$MainForm.BackColor = "#363636"
	
$MainForm.WindowState =[System.Windows.Forms.FormWindowState]::Normal

$tabs.add_SelectedIndexChanged($handler_tabpage_SelectedIndexChanged)
$MainForm.ShowDialog()

