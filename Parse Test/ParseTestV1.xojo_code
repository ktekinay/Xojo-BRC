#tag Class
Protected Class ParseTestV1
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
		  
		  for i as integer = 0 to rows.LastIndex
		    var row as string = rows( i )
		    
		    var parts() as string = row.SplitBytes( ";" )
		    var name as string = parts( 0 )
		    result = result + name.Bytes
		    
		    var temp as integer = parts( 1 ).ToDouble * 10.0
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
