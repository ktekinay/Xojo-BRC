#tag Class
Protected Class ParseTestV4
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
		  
		  //
		  // Fowler-Noll-Vo hash
		  // https://en.wikipedia.org/wiki/Fowler-Noll-Vo_hash_function
		  //
		  const kFNVOffsetBasis as UInt64 = &hcbf29ce484222325
		  const kFNVPrime as UInt64 = &h100000001b3
		  
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
		  
		  var byteIndex as integer
		  var mult as integer
		  
		  var hash as UInt64 = kFNVOffsetBasis
		  var b as byte
		  
		  do
		    byteIndex = byteIndex + 1
		    if byteIndex = mb.Size then
		      exit
		    end if
		    
		    b = p.Byte( byteIndex )
		    
		    if inName then
		      if b = kSemiColonByte then
		        inName = false
		        result = result + ( byteIndex - nameStartByte )
		        
		        if p.Byte( byteIndex + 1 ) = kHyphenByte then
		          mult = -1
		          byteIndex = byteIndex + 1
		        else
		          mult = 1
		        end if
		        
		      else
		        hash = ( hash * kFNVPrime ) xor b
		      end if
		      
		    else // not inName
		      select case b
		      case kEOLByte
		        inName = true
		        nameStartByte = byteIndex + 1
		        
		        temp = temp * mult
		        result = result + temp
		        
		        hash = kFNVOffsetBasis
		        temp = 0
		        
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
