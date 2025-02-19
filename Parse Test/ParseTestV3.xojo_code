#tag Class
Protected Class ParseTestV3
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
		  
		  const kSemiColonByte as integer = 59
		  const kHyphenByte as integer = 45
		  const kEOLByte as integer = 10
		  const kZeroByte as integer = 48
		  const kDotByte as integer = 46
		  
		  var mb as MemoryBlock = s
		  mb.Size = mb.Size + 1
		  
		  var p as ptr = mb
		  p.Byte( mb.Size - 1 ) = kEOLByte
		  
		  var inName as boolean = true
		  var nameStartByte as integer = 0
		  var temp as integer
		  var name as string
		  
		  var byteIndex as integer
		  var mult as integer
		  
		  do
		    byteIndex = byteIndex + 1
		    if byteIndex = mb.Size then
		      exit
		    end if
		    
		    var b as integer = p.Byte( byteIndex )
		    
		    if inName then
		      if b = kSemiColonByte then
		        inName = false
		        name = mb.StringValue( nameStartByte, byteIndex - nameStartByte, Encodings.UTF8 )
		        result = result + name.Bytes
		        
		        if p.Byte( byteIndex + 1 ) = kHyphenByte then
		          mult = -1
		          byteIndex = byteIndex + 1
		        else
		          mult = 1
		        end if
		        
		        temp = 0
		      end if
		      
		    else // not inName
		      select case b
		      case kEOLByte
		        inName = true
		        nameStartByte = byteIndex + 1
		        
		        temp = temp * mult
		        result = result + temp
		        
		      case kDotByte
		        
		      case else
		        temp = ( temp * 10 ) + ( b - kZeroByte )
		        
		      end select
		    end if
		  loop
		  
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
