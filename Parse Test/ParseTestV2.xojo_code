#tag Class
Protected Class ParseTestV2
Inherits ParseTestBase
	#tag Method, Flags = &h0
		Function Parse(s As String) As Integer
		  #if not DebugBuild then
		    #pragma BackgroundTasks false
		  #endif
		  #pragma BoundsChecking false
		  #pragma NilObjectChecking false
		  #pragma StackOverflowChecking false
		  
		  var result as integer
		  
		  var rows() as string = s.SplitBytes( EndOfLine )
		  
		  var name as string
		  var temp as integer
		  var parts() as string
		  var row as string
		  
		  for i as integer = 0 to rows.LastIndex
		    row = rows( i )
		    
		    parts = row.SplitBytes( ";" )
		    name = parts( 0 )
		    result = result + name.Bytes
		    
		    temp = parts( 1 ).ReplaceBytes( ".", "" ).ToInteger
		    result = result + temp
		  next
		  
		  return result
		  
		End Function
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
