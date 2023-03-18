B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=5.5
@EndOfDesignText@
'Class module
Sub Class_Globals
	Public 	tv 									As List
	Private 		pnlIndex 					As Panel
	Private 		hoverLabel 					As Label
	Private const 	PANEL_INDEX_WIDTH 			As Float = 40dip
	Private 		hoverLabelTopMargin 		As Int
	Private lblLast As Label
End Sub

Public Sub Initialize (vEventName As String)
	
	Starter.LogShowToast = False
	Starter.MyLog("Alphabet Initialize = " & vEventName, Colors.Yellow, True)
	
	pnlIndex.Initialize("pnlIndex")
	Dim cd As ColorDrawable
		cd.Initialize2(Colors.White, 12dip, 2dip, 0xFF3A89D3)
	hoverLabel.Initialize("")
	hoverLabel.Background = cd
	hoverLabel.TextColor = 0xFF3A89D3
	hoverLabel.Visible = False
	hoverLabel.Gravity = Gravity.CENTER
	hoverLabel.TextSize = 18
	
End Sub

Public Sub DesignerCreateView (base As Panel, lbl As Label, props As Map)

End Sub

Public Sub LoadAlphabetlist (base 			As Panel, _
							 Alphalist 		As Map, _
							 justCleanTable As Boolean, _
							 top 			As Int)
	
'	Starter.LogShowToast = False
'	Starter.MyLog("IndexedTable: LoadAlphabetlist")
	
	pnlIndex.RemoveView
	pnlIndex.RemoveAllViews
	hoverLabel.RemoveView
	
	If (justCleanTable) Then Return
	
	hoverLabelTopMargin = top
	
	base.AddView(pnlIndex, base.Width - PANEL_INDEX_WIDTH, top, PANEL_INDEX_WIDTH, base.Height - Starter.NAVBARHEIGHT)
	base.AddView(hoverLabel, base.Width - 100dip, top, 40dip, 40dip)
	Dim lblHeight As Float = (pnlIndex.Height - 2dip) / 26 'Alphalist.Size
	
	Dim i As Int = 0
	For Each alpha As String In Alphalist.Keys
		Dim lbl As Label
			lbl.Initialize("lbl")
			lbl.Text = Alphalist.GetKeyAt(i)
			lbl.Tag = Alphalist.Get(alpha)
			lbl.TextColor = 0x3DFFFFFF '0x46FFFFFF
			lbl.Gravity = Gravity.CENTER
		pnlIndex.AddView(lbl, 0, 2dip + i * lblHeight, PANEL_INDEX_WIDTH, 20dip)
'		LogColor(Alphalist.GetKeyAt(i) & " : " & Alphalist.Get(alpha), Colors.Blue)
		i = i + 1
	Next
	base.Color = Colors.Transparent
End Sub

Private Sub pnlIndex_Touch(Action As Int, X As Float, Y As Float)
	
	If (Action = pnlIndex.ACTION_DOWN) Then _
		Starter.MyLog("****** IndexedTable: pnlIndex_Touch Down= Action: " & Action, 0, True)
	
	hoverLabel.Visible = False
	B4XPages.MainPage.HideAppMenu(True)
	
	Try
		Dim item As Int = Y / (pnlIndex.Height - 250) * pnlIndex.NumberOfViews
		item = Min(item, pnlIndex.NumberOfViews - 1)
	
		If (item < 0) Then Return
	
		Dim lbl As Label = pnlIndex.GetView(item)
		If Action = pnlIndex.ACTION_UP Then
			hoverLabel.Visible = False
'			LogColor(lbl.Tag, Colors.Red)
			B4XPages.MainPage.clvApps.ScrollToItem(lbl.Tag)
		Else
			If (lbl <> lblLast) And (lbl.Text <> "") Then _
				XUIViewsUtils.PerformHapticFeedback(Sender)
			
			hoverLabel.Top = (lbl.Top - 15dip) + hoverLabelTopMargin
			hoverLabel.Text = lbl.Text
			hoverLabel.Visible = True
			B4XPages.MainPage.clvApps.ScrollToItem(lbl.Tag)
			lblLast = lbl
		End If
	Catch
		Log("pnlIndex_Touch: " & LastException)
	End Try
End Sub

Public Sub HideHoverLabel
	hoverLabel.Visible = False
End Sub
