B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=12.15
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	
	Public AndroidSetting As AndroidSettings
		AndroidSetting.WirelessSettings = "WirelessSettings"
		AndroidSetting.WifiSettings = "WifiSettings"
		AndroidSetting.AdvancedWifiSettings = "AdvancedWifiSettings"
		AndroidSetting.BluetoothSettings = "BluetoothSettings"
		AndroidSetting.TetherSettings = "TetherSettings"
		AndroidSetting.WifiP2pSettings = "WifiP2pSettings"
		AndroidSetting.VpnSettings = "VpnSettings"
		AndroidSetting.DateTimeSettings = "DateTimeSettings"
		AndroidSetting.LocalePicker = "LocalePicker"
		AndroidSetting.InputMethodAndLanguageSettings = "InputMethodAndLanguageSettings"
		AndroidSetting.SpellCheckersSettings = "SpellCheckersSettings"
		AndroidSetting.UserDictionaryList = "UserDictionaryList"
		AndroidSetting.UserDictionarySettings = "UserDictionarySettings"
		AndroidSetting.SoundSettings = "SoundSettings"
		AndroidSetting.DeviceInfoSettings = "DeviceInfoSettings"
		AndroidSetting.ManageApplications = "ManageApplications"
		AndroidSetting.ProcessStatsUi = "ProcessStatsUi"
'		AndroidSetting.NotificationStation = "NotificationStation"
		AndroidSetting.LocationSettings = "LocationSettings"
		AndroidSetting.SecuritySettings = "SecuritySettings"
		AndroidSetting.PrivacySettings = "PrivacySettings"
		AndroidSetting.DeviceAdminSettings = "DeviceAdminSettings"
		AndroidSetting.AccessibilitySettings = "AccessibilitySettings"
		AndroidSetting.ToggleCaptioningPreferenceFragment = "ToggleCaptioningPreferenceFragment"
		AndroidSetting.TextToSpeechSettings = "TextToSpeechSettings"
		AndroidSetting.Memory = "Memory"
		AndroidSetting.DevelopmentSettings = "DevelopmentSettings"
		AndroidSetting.UsbSettings = "UsbSettings"
		AndroidSetting.AndroidBeam = "AndroidBeam"
		AndroidSetting.WifiDisplaySettings = "WifiDisplaySettings"
		AndroidSetting.PowerUsageSummary = "PowerUsageSummary"
		AndroidSetting.AccountSyncSettings = "AccountSyncSettings"
		AndroidSetting.CryptKeeperSettings = "CryptKeeperSettings"
		AndroidSetting.DataUsageSummary = "DataUsageSummary"
		AndroidSetting.DreamSettings = "DreamSettings"
'		AndroidSetting.UserSettings = "UserSettings"
		AndroidSetting.NotificationAccessSettings = "NotificationAccessSettings"
		AndroidSetting.ManageAccountsSettings = "ManageAccountsSettings"
		AndroidSetting.PrintSettingsFragment = "PrintSettingsFragment"
		AndroidSetting.PrintJobSettingsFragment = "PrintJobSettingsFragment"
		AndroidSetting.TrustedCredentialsSettings = "TrustedCredentialsSettings"
		AndroidSetting.PaymentSettings = "PaymentSettings"
		AndroidSetting.KeyboardLayoutPickerFragment = "KeyboardLayoutPickerFragment"
		AndroidSetting.InstalledAppDetails = "InstalledAppDetails"
	
	Type AndroidSettings(WirelessSettings As String, _
						WifiSettings As String, _
						AdvancedWifiSettings As String, _
						BluetoothSettings As String, _
						TetherSettings As String, _
						WifiP2pSettings As String, _
						VpnSettings As String, _
						LocalePicker As String, _
						InputMethodAndLanguageSettings As String, _
						SpellCheckersSettings As String, _
						UserDictionaryList As String, _
						UserDictionarySettings As String, _
						SoundSettings As String, _
						DisplaySettings As String, _
						DeviceInfoSettings As String, _
						ManageApplications As String, _
						ProcessStatsUi As String, _
						NotificationStation As String, _
						LocationSettings As String, _
						SecuritySettings As String, _
						PrivacySettings As String, _
						DeviceAdminSettings As String, _
						AccessibilitySettings As String, _
						ToggleCaptioningPreferenceFragment As String, _
						TextToSpeechSettings As String, _
						Memory As String, _
						DevelopmentSettings As String, _
						UsbSettings As String, _
						AndroidBeam As String, _
						WifiDisplaySettings As String, _
						PowerUsageSummary As String, _
						AccountSyncSettings As String, _
						CryptKeeperSettings As String, _
						DataUsageSummary As String, _
						DreamSettings As String, _
						UserSettings As String, _
						NotificationAccessSettings As String, _
						ManageAccountsSettings As String, _
						PrintSettingsFragment As String, _
						PrintJobSettingsFragment As String, _
						TrustedCredentialsSettings As String, _
						PaymentSettings As String, _
						KeyboardLayoutPickerFragment As String, _
						DateTimeSettings As String, _
						InstalledAppDetails As String)

End Sub