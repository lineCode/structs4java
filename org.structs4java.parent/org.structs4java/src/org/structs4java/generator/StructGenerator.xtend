/*
 * generated by Xtext 2.10.0
 */
package org.structs4java.generator

import org.structs4java.structs4JavaDsl.ComplexTypeDeclaration
import org.structs4java.structs4JavaDsl.ComplexTypeMember
import org.structs4java.structs4JavaDsl.FloatMember
import org.structs4java.structs4JavaDsl.IntegerMember
import org.structs4java.structs4JavaDsl.Member
import org.structs4java.structs4JavaDsl.Package
import org.structs4java.structs4JavaDsl.StringMember
import org.structs4java.structs4JavaDsl.StructDeclaration
import org.structs4java.structs4JavaDsl.EnumDeclaration

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class StructGenerator {

	def compile(Package pkg, StructDeclaration struct) '''
		«packageDeclaration(pkg)»
		
		«printComments(struct)»
		public class «struct.name» {
			public «struct.name»() {
			}
			
			«readerMethodForStruct(struct)»
			«writerMethodForStruct(struct)»
			
			«getters(struct)»
			«setters(struct)»
			
			«sizeOfStructMethod(struct)»
			
			«toStringMethod(struct)»
			«hashCodeMethod(struct)»
			«equalsMethod(struct)»
			
			«readerMethods(struct)»
			«writerMethods(struct)»
			
			«fields(struct)»
		}
	'''
	
	def printComments(StructDeclaration struct) '''
	/**
	«FOR comment : struct.comments»
	* «comment.substring(2).trim()»
	«ENDFOR»
	*/
	'''
	
	def printComments(Member member) '''
	/**
	«FOR comment : member.comments»
	* «comment.substring(2).trim()»
	«ENDFOR»
	*/
	'''
	
	def sizeOfStructMethod(StructDeclaration struct) '''
	«IF struct.isFixedSize()»
	public static long getSizeOf() {
		return «computeFixedSizeOf(struct)»;
	}
	«ENDIF»
	'''
	
	def hashCodeMethod(StructDeclaration struct) '''
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		«FOR m : struct.members»
		«IF !m.hasSizeOfOrCountOfAttribute()»
		«IF m instanceof StringMember || m instanceof ComplexTypeMember || m.isArray()»
		result = prime * result + ((this.«attributeName(m)» == null) ? 0 : this.«attributeName(m)».hashCode());
		«ELSEIF m instanceof IntegerMember»
		«IF (m as IntegerMember).typename.equals("int8_t") || (m as IntegerMember).typename.equals("uint8_t")»
		result = prime * result + this.«attributeName(m)»;
		«ELSEIF (m as IntegerMember).typename.equals("int16_t") || (m as IntegerMember).typename.equals("uint16_t")»
		result = prime * result + this.«attributeName(m)»;
		«ELSEIF (m as IntegerMember).typename.equals("int32_t") || (m as IntegerMember).typename.equals("uint32_t")»
		result = prime * result + this.«attributeName(m)»;
		«ELSEIF (m as IntegerMember).typename.equals("int64_t") || (m as IntegerMember).typename.equals("uint64_t")»
		result = prime * result + (int) (this.«attributeName(m)» ^ (this.«attributeName(m)» >>> 32));
		«ENDIF»
		«ELSEIF m instanceof FloatMember»
		«IF (m as FloatMember).typename.equals("float")»
		result = prime * result + Float.floatToIntBits(this.«attributeName(m)»);
		«ELSEIF (m as FloatMember).typename.equals("double")»
		{
			long temp;
			temp = Double.doubleToLongBits(this.«attributeName(m)»);
			result = prime * result + (int) (temp ^ (temp >>> 32));
		}
		«ENDIF»
		«ENDIF»	
		«ENDIF»
		«ENDFOR»	
		return result;
	}
	'''
	
	def equalsMethod(StructDeclaration struct) '''
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		«struct.name» other = («struct.name») obj;
		
		«FOR m : struct.members»
			«IF !m.hasSizeOfOrCountOfAttribute()»
				«IF m instanceof StringMember || m instanceof ComplexTypeMember || m.isArray()»
					if (this.«attributeName(m)» == null) {
						if (other.«attributeName(m)» != null)
							return false;
					} else if (!this.«attributeName(m)».equals(other.«attributeName(m)»))
						return false;
				«ELSEIF m instanceof IntegerMember»
					«IF (m as IntegerMember).typename.equals("int8_t") || (m as IntegerMember).typename.equals("uint8_t")»
						if (this.«attributeName(m)» != other.«attributeName(m)»)
							return false;
					«ELSEIF (m as IntegerMember).typename.equals("int16_t") || (m as IntegerMember).typename.equals("uint16_t")»
						if (this.«attributeName(m)» != other.«attributeName(m)»)
							return false;
					«ELSEIF (m as IntegerMember).typename.equals("int32_t") || (m as IntegerMember).typename.equals("uint32_t")»
						if (this.«attributeName(m)» != other.«attributeName(m)»)
							return false;
					«ELSEIF (m as IntegerMember).typename.equals("int64_t") || (m as IntegerMember).typename.equals("uint64_t")»
						if (this.«attributeName(m)» != other.«attributeName(m)»)
							return false;
					«ENDIF»
				«ELSEIF m instanceof FloatMember»
					«IF (m as FloatMember).typename.equals("float")»
						if (Float.floatToIntBits(this.«attributeName(m)») != Float.floatToIntBits(other.«attributeName(m)»))
							return false;
					«ELSEIF (m as FloatMember).typename.equals("double")»
						if (Double.doubleToLongBits(this.«attributeName(m)») != Double.doubleToLongBits(other.«attributeName(m)»))
							return false;
					«ENDIF»
				«ENDIF»	
			«ENDIF»
		«ENDFOR»
		return true;
	}
	'''
	
	def toStringMethod(StructDeclaration struct) '''
	public String toString() {
		StringBuilder buf = new StringBuilder("«javaType(struct)»[");
		«FOR m : struct.nonTransientMembers() SEPARATOR "buf.append(\", \");"»
			buf.append("«attributeName(m)»=" + «getterName(m)»());
		«ENDFOR»
		buf.append("]");
		return buf.toString();
	}
	'''
	
	def nonTransientMembers(StructDeclaration struct) {
		return struct.members.filter[!isTransient];
	}
	
	def isTransient(Member m) {
		return m.hasSizeOfOrCountOfAttribute()
	}
	
	def readerMethods(StructDeclaration struct) '''
		«FOR m : struct.members»
			«readerMethodForMember(m)»
		«ENDFOR»
	'''

	def readerMethodForStruct(StructDeclaration struct) '''
		public static «struct.name» read(java.nio.ByteBuffer buf) throws java.io.IOException {
			return read(buf, false);
		}
		
		public static «struct.name» read(java.nio.ByteBuffer buf, boolean partialRead) throws java.io.IOException {
			if(buf.remaining() == 0) {
				// avoid empty object construction for partial reads
				throw new java.nio.BufferUnderflowException();
			}
			«IF struct.isSelfSized()»
			long structBeginPosition = buf.position();
			long structEndPosition = -1;
			«ENDIF»
			
			«struct.name» obj = new «struct.name»();
			
			try {
			«FOR m : struct.members»
				«IF m.hasSizeOfOrCountOfAttribute()»
					«IF (m as IntegerMember).sizeofThis»
						structEndPosition = structBeginPosition + «readerMethodName(m)»(buf, partialRead);
					«ELSE»
						«IF struct.isSelfSized()»
							if(buf.position() == structEndPosition) {
								return obj;
							}
							if(buf.position() > structEndPosition) {
								throw new java.io.IOException(String.format("Read beyond the memory region of the struct [%d,%d) definition by %d bytes", structBeginPosition, structEndPosition, buf.position() - structEndPosition));
							}
						«ENDIF»
						«attributeJavaType(m)» «tempVarForMember(m)» = «readerMethodName(m)»(buf, partialRead);
						obj.«attributeName(m)» = «tempVarForMember(m)»;
					«ENDIF»
				«ELSE»
					«IF struct.isSelfSized()»
						if(buf.position() == structEndPosition) {
							return obj;
						}
						if(structEndPosition != -1 && buf.position() > structEndPosition) {
							throw new java.io.IOException(String.format("Read beyond the memory region of the struct [%d,%d) definition by %d bytes", structBeginPosition, structEndPosition, buf.position() - structEndPosition));
						}
					«ENDIF»
					
					«IF findMemberDefiningSizeOf(m) != null»
						«IF m instanceof ComplexTypeMember»
						{
							java.nio.ByteBuffer slice = buf.slice();
							slice.limit(«tempVarForMember(findMemberDefiningSizeOf(m))»);
							obj.«setterName(m)»(«readerMethodName(m)»(slice, true));
						}
						«ELSE»
						obj.«setterName(m)»(«readerMethodName(m)»(buf, partialRead, «tempVarForMember(findMemberDefiningSizeOf(m))»));
						«ENDIF»
					«ELSEIF findMemberDefiningCountOf(m) != null»
						«IF m instanceof ComplexTypeMember»
						{
							java.nio.ByteBuffer slice = buf.slice();
							slice.limit(«tempVarForMember(findMemberDefiningCountOf(m))»);
							obj.«setterName(m)»(«readerMethodName(m)»(slice, true));
						}
						«ELSE»
						obj.«setterName(m)»(«readerMethodName(m)»(buf, partialRead, «tempVarForMember(findMemberDefiningCountOf(m))»));
						«ENDIF»
					«ELSE»
						«IF m.isArray() && !m.isString() && m.isGreedy()»
							«IF struct.isSelfSized()»
							obj.«setterName(m)»(«readerMethodName(m)»(buf, partialRead, (int)(structEndPosition - buf.position())));
							«ELSE»
							// greedy member
							obj.«setterName(m)»(«readerMethodName(m)»(buf, partialRead, buf.limit() - buf.position()));
							«ENDIF»
						«ELSE»
						obj.«setterName(m)»(«readerMethodName(m)»(buf, partialRead));
						«ENDIF»
					«ENDIF»
				«ENDIF»
			«ENDFOR»
			} catch(java.nio.BufferUnderflowException e) {
				if(!partialRead) {
					throw e;
				}
			}
			
			return obj;
		}
	'''
	
	def isSelfSized(StructDeclaration struct) {
		for(Member m : struct.members) {
			if(m instanceof IntegerMember) {
				if(m.sizeofThis) {
					return true;
				}
			}
		}
		return false;
	}
	
	def tempVarForMember(Member m) {
		if(m.hasSizeOfAttribute()) {
			return "sizeof__" + attributeName((m as IntegerMember).sizeof)				
		} else {
			return "countof__" + attributeName((m as IntegerMember).countof)
		}
	}
	
	def readerMethodName(Member m) {
		return "read" + m.name.toFirstUpper;
	}

	def isArray(Member m) {
		return m.array != null
	}
	
	def isGreedy(Member m) {
		if(m.array == null) {
			return false;
		}
		
		if(m.array.dimension > 0) {
			return false;
		}
		
		return true;
	}
	
	def isString(Member m) {
		return m instanceof StringMember;
	}
	
	def findMemberDefiningSizeOrCountOf(Member m) {
		var m2 = findMemberDefiningSizeOf(m)
		if(m2 != null) {
			return m2
		}
		return findMemberDefiningCountOf(m)
	}

	def findMemberDefiningSizeOf(Member m) {
		val struct = m.eContainer as StructDeclaration;
		for (member : struct.members) {
			if (member instanceof IntegerMember) {
				if (m.equals(member.sizeof)) {
					return member
				}
			}
		}
		return null
	}
	
	def findMemberDefiningCountOf(Member m) {
		val struct = m.eContainer as StructDeclaration;
		for (member : struct.members) {
			if (member instanceof IntegerMember) {
				if (m.equals(member.countof)) {
					return member
				}
			}
		}
		return null
	}

	def setterName(Member m) {
		return "set" + attributeName(m).toFirstUpper();
	}

	def getterName(Member m) {
		return "get" + attributeName(m).toFirstUpper();
	}

	def attributeName(Member m) {
		return m.name;
	}

	def readerMethodForMember(Member m) {
		if(m.isArray()) {
			switch (m) {
				IntegerMember case m.typename == "uint8_t": readerMethodForByteBuffer(m)
				IntegerMember case m.typename == "int8_t": readerMethodForByteBuffer(m)
				StringMember: readerMethodForStringMember(m)
				default: readerMethodForArrayMember(m)
			}
		} else  {
			readerMethodForPrimitive(m)		
		}
	}
	
	def readerMethodForPrimitive(Member m) {
		switch (m) {
			ComplexTypeMember: readerMethodForComplexTypeMember(m)
			IntegerMember: readerMethodForIntegerMember(m)
			FloatMember: readerMethodForFloatMember(m)
			StringMember: readerMethodForStringMember(m)
		}
	}
	
	def getDefiningStruct(Member m) {
		return m.eContainer as StructDeclaration;
	}
	
	def readerMethodForArrayMember(Member m) '''
	private static java.util.ArrayList<«m.nativeTypeName().native2JavaType().box()»> «m.readerMethodName()»(java.nio.ByteBuffer buf, boolean partialRead«IF dimensionOf(m) == 0», int countof«ENDIF») throws java.io.IOException {
		java.util.ArrayList<«m.nativeTypeName().native2JavaType().box()»> lst = new java.util.ArrayList<«m.nativeTypeName().native2JavaType().box()»>();
		try {
		«IF dimensionOf(m) == 0»
		for(int i = 0; i < countof; ++i) {
			lst.add(«readerMethodName(m)»«arrayPostfix(m)»(buf, partialRead));
		}
		«ELSE»
		«FOR i : 0 ..< dimensionOf(m)»
		lst.add(«readerMethodName(m)»«arrayPostfix(m)»(buf, partialRead));
		«ENDFOR»
		«ENDIF»
		} catch(java.nio.BufferUnderflowException e) {
			if(!partialRead) {
				throw e;
			}
		}
		return lst;
	}
	
	«readerMethodForPrimitive(m)»
	'''
	
	def dimensionOf(Member m) {
		if(m.array == null) {
			return 0;
		}
		return m.array.dimension;
	}
	
	def readerMethodForByteBuffer(IntegerMember m) '''
		private static java.nio.ByteBuffer «readerMethodName(m)»(java.nio.ByteBuffer buf, boolean partialRead«IF dimensionOf(m) == 0», int sizeof«ENDIF») throws java.io.IOException {
			byte[] buffer = new byte[«IF dimensionOf(m) == 0»sizeof«ELSE»«dimensionOf(m)»«ENDIF»];
			buf.get(buffer);
			return java.nio.ByteBuffer.wrap(buffer); 
		}
	'''

	def readerMethodForComplexTypeMember(ComplexTypeMember m) '''
		private static «m.nativeTypeName().native2JavaType()» «m.readerMethodName()»«arrayPostfix(m)»(java.nio.ByteBuffer buf, boolean partialRead) throws java.io.IOException {
			return «m.nativeTypeName().native2JavaType()».read(buf, partialRead);
		}
	'''
	
	def readerMethodForIntegerMember(IntegerMember m) '''
		private static «m.nativeTypeName().native2JavaType()» «m.readerMethodName()»«arrayPostfix(m)»(java.nio.ByteBuffer buf, boolean partialRead) throws java.io.IOException {
			«IF m.typename.equals("int8_t")»
			return buf.get();
			«ELSEIF m.typename.equals("uint8_t")»
			return buf.get() & 0xFF;
			«ELSEIF m.typename.equals("int16_t")»
			return buf.getShort();
			«ELSEIF m.typename.equals("uint16_t")»
			return buf.getShort() & 0xFFFF;
			«ELSEIF m.typename.equals("int32_t")»
			return buf.getInt();
			«ELSEIF m.typename.equals("uint32_t")»
			return buf.getInt() & 0xFFFFFFFF;
			«ELSEIF m.typename.equals("int64_t")»
			return buf.getLong();
			«ELSEIF m.typename.equals("uint64_t")»
			return buf.getLong() & 0xFFFFFFFFFFFFFFFFL;
			«ENDIF»
		}
	'''

	def readerMethodForFloatMember(FloatMember m) '''
		private static «m.nativeTypeName().native2JavaType()» «m.readerMethodName()»«arrayPostfix(m)»(java.nio.ByteBuffer buf, boolean partialRead) throws java.io.IOException {
			«IF m.typename.equals("float")»
			return buf.getFloat();
			«ELSEIF m.typename.equals("double")»
			return buf.getDouble();
			«ENDIF»
		}
	'''

	def readerMethodForStringMember(StringMember m) '''
		private static String «m.readerMethodName()»(java.nio.ByteBuffer buf, boolean partialRead«IF dimensionOf(m) == 0 && findMemberDefiningSizeOf(m) != null», «attributeJavaType(findMemberDefiningSizeOrCountOf(m))» sizeof«ENDIF») throws java.io.IOException {
			try {
			«IF dimensionOf(m) == 0»
				«IF findMemberDefiningSizeOf(m) == null»
				java.io.ByteArrayOutputStream tmp = new java.io.ByteArrayOutputStream();
				int terminatingZeros = "\0".getBytes("«encodingOf(m)»").length;
				int zerosRead = 0;
				while(zerosRead < terminatingZeros) {
					int b = buf.get();
					tmp.write(b);
					if(b == 0) {
						zerosRead++;
					} else {
						zerosRead = 0;
					}
				}
				return new String(tmp.toByteArray(), 0, tmp.size() - zerosRead, "«encodingOf(m)»");
				«ELSE»
				byte[] tmp = new byte[sizeof];
				buf.get(tmp);
				return new String(tmp, "«encodingOf(m)»");
				«ENDIF»
			«ELSE»
				byte[] tmp = new byte[«dimensionOf(m)»];
				buf.get(tmp);
				int terminatingZeros = "\0".getBytes("«encodingOf(m)»").length;
				int zerosRead = 0;
				int i = 0;
				int len = 0;
				while(zerosRead < terminatingZeros) {
					if(i >= «dimensionOf(m)») {
						len = i;
						break;
					}
					if(tmp[i++] == 0) {
						zerosRead++;
					} else {
						zerosRead = 0;
						len = i;
					}
				}
				return new String(tmp, 0, len, "«encodingOf(m)»");
			«ENDIF»
			} catch(java.io.UnsupportedEncodingException e) {
				throw new java.io.IOException(e);
			}
		}
	'''
	
	def arrayPostfix(Member m) {
		if(m.isArray()) {
			return "_ArrayItem"
		}
		return ""
	}
	
	def writerMethodName(Member m) {
		return "write" + m.name.toFirstUpper;
	}

	def writerMethodForStruct(StructDeclaration struct) '''
		public void write(java.nio.ByteBuffer buf) throws java.io.IOException {
			«IF struct.isSelfSized()»
			int beginOfStruct = buf.position();
			«ENDIF»
			«FOR m : struct.members»
				«IF m.isTransient()»
				int positionof__«attributeName(m)» = buf.position();
				buf.position(buf.position() + «computeFixedSizeOf(m)»);
				«ELSE»
					«IF m.findMemberDefiningSizeOrCountOf() != null»
						int positionof__«attributeName(m)» = buf.position();
						«writerMethodName(m)»(buf);
						«attributeJavaType(m.findMemberDefiningSizeOrCountOf())» «attributeName(m.findMemberDefiningSizeOrCountOf())» = («attributeJavaType(m.findMemberDefiningSizeOrCountOf())»)(buf.position() - positionof__«attributeName(m)»);
						positionof__«attributeName(m)» = buf.position();
						buf.position(positionof__«attributeName(m.findMemberDefiningSizeOrCountOf())»);
						«writerMethodName(m.findMemberDefiningSizeOrCountOf())»(buf, «attributeName(m.findMemberDefiningSizeOrCountOf())»);
						buf.position(positionof__«attributeName(m)»);
					«ELSE»
						«writerMethodName(m)»(buf);
					«ENDIF»
				«ENDIF»
			«ENDFOR»
			
			«IF struct.isSelfSized()»
			int endOfStruct = buf.position();
			buf.position(positionof__«attributeName(selfSizeMember(struct))»);
			«writerMethodName(selfSizeMember(struct))»(buf, endOfStruct - beginOfStruct);
			buf.position(endOfStruct);
			«ENDIF»
		}
	'''
	
	def selfSizeMember(StructDeclaration struct) {
		for(Member m : struct.members) {
			if(m instanceof IntegerMember) {
				if(m.sizeofThis) {
					return m
				}
			}
		}
		return null
	}
	
	def writerMethods(StructDeclaration struct) '''
		«FOR m : struct.members»
			«writerMethodForMember(m)»
		«ENDFOR»
	'''
	
	def hasSizeOfOrCountOfAttribute(Member m) {
		return m.hasSizeOfAttribute() || m.hasCountOfAttribute()
	}
	
	def hasSizeOfAttribute(Member m) {
		if(m instanceof IntegerMember) {
			return m.sizeof != null || m.sizeofThis;
		}
		return false;
	}
	
	def hasCountOfAttribute(Member m) {
		if(m instanceof IntegerMember) {
			return m.countof != null;
		}
		return false;
	}
	
	def writerMethodForMember(Member m) {
		if(m.isTransient()) {
			return writerMethodForIntegerMemberReceivingValue(m as IntegerMember)
		}
		
		if(isArray(m)) {
			switch (m) {
				IntegerMember case m.typename == "uint8_t": return writerMethodForByteBuffer(m)
				IntegerMember case m.typename == "int8_t": return writerMethodForByteBuffer(m)
				StringMember: return writerMethodForString(m)
				default: return writerMethodForArrayMember(m)
			}
		} else  {
			return writerMethodForPrimitive(m)		
		}
	}
	
	def writerMethodForPrimitive(Member m) {
		switch (m) {
			ComplexTypeMember: writerMethodForComplexTypeMember(m)
			IntegerMember: writerMethodForIntegerMember(m)
			FloatMember: writerMethodForFloatMember(m)
			StringMember: writerMethodForString(m)
		}
	}
	
	def writerMethodForArrayMember(Member m) '''
	private void «m.writerMethodName()»(java.nio.ByteBuffer buf) throws java.io.IOException {
		java.util.ArrayList<«m.nativeTypeName().native2JavaType().box()»> lst = «getterName(m)»();
		«IF dimensionOf(m) == 0»
		for(«m.nativeTypeName().native2JavaType().box()» item : lst) {
			«writerMethodName(m)»«arrayPostfix(m)»(buf, item);
		}
		«ELSE»
		«FOR i : 0 ..< dimensionOf(m)»
		«writerMethodName(m)»«arrayPostfix(m)»(buf, lst.get(«i»));
		«ENDFOR»
		«ENDIF»
	}
	
	«writerMethodForPrimitive(m)»
	'''
	
	def writerMethodForByteBuffer(IntegerMember m) '''
		private void «m.writerMethodName()»(java.nio.ByteBuffer buf) throws java.io.IOException {
			buf.put(«getterName(m)»());
		}
	'''

	def writerMethodForComplexTypeMember(ComplexTypeMember m) '''
		private void «m.writerMethodName()»«arrayPostfix(m)»(java.nio.ByteBuffer buf«IF m.isArray()», «m.nativeTypeName().native2JavaType()» value«ENDIF») throws java.io.IOException {
			if(«IF m.isArray()»value«ELSE»«getterName(m)»()«ENDIF» != null) {
				«IF m.isArray()»value«ELSE»«getterName(m)»()«ENDIF».write(buf);
			}
		}
	'''

	def writerMethodForIntegerMember(IntegerMember m) '''
	«IF m.isArray()»
		«writerMethodForIntegerMemberReceivingValue(m)»
	«ELSE»
		private void «m.writerMethodName()»«arrayPostfix(m)»(java.nio.ByteBuffer buf) throws java.io.IOException {
			«IF m.typename.equals("int8_t")»
			buf.put((byte)«getterName(m)»());
			«ELSEIF m.typename.equals("uint8_t")»
			buf.put((byte)«getterName(m)»());
			«ELSEIF m.typename.equals("int16_t")»
			buf.putShort((short)«getterName(m)»());
			«ELSEIF m.typename.equals("uint16_t")»
			buf.putShort((short)«getterName(m)»());
			«ELSEIF m.typename.equals("int32_t")»
			buf.putInt(«getterName(m)»());
			«ELSEIF m.typename.equals("uint32_t")»
			buf.putInt(«getterName(m)»());
			«ELSEIF m.typename.equals("int64_t")»
			buf.putLong(«getterName(m)»());
			«ELSEIF m.typename.equals("uint64_t")»
			buf.putLong(«getterName(m)»());
			«ENDIF»
		}
	«ENDIF»
	'''
	
	def writerMethodForIntegerMemberReceivingValue(IntegerMember m) '''
		private void «m.writerMethodName()»«arrayPostfix(m)»(java.nio.ByteBuffer buf, «m.nativeTypeName().native2JavaType()» value) throws java.io.IOException {
			«IF m.typename.equals("int8_t")»
			buf.put((byte)value);
			«ELSEIF m.typename.equals("uint8_t")»
			buf.put((byte)value);
			«ELSEIF m.typename.equals("int16_t")»
			buf.putShort((short)value);
			«ELSEIF m.typename.equals("uint16_t")»
			buf.putShort((short)value);
			«ELSEIF m.typename.equals("int32_t")»
			buf.putInt(value);
			«ELSEIF m.typename.equals("uint32_t")»
			buf.putInt(value);
			«ELSEIF m.typename.equals("int64_t")»
			buf.putLong(value);
			«ELSEIF m.typename.equals("uint64_t")»
			buf.putLong(value);
			«ENDIF»
		}
	'''

	def writerMethodForFloatMember(FloatMember m) '''
		private void «m.writerMethodName()»«arrayPostfix(m)»(java.nio.ByteBuffer buf«IF m.isArray()», «m.nativeTypeName().native2JavaType()» value«ENDIF») throws java.io.IOException {
			«IF m.typename.equals("float")»
			buf.putFloat(«IF m.isArray()»value«ELSE»«getterName(m)»()«ENDIF»);
			«ELSEIF m.typename.equals("double")»
			buf.putDouble(«IF m.isArray()»value«ELSE»«getterName(m)»()«ENDIF»);
			«ENDIF»
		}
	'''

	def writerMethodForString(StringMember m) '''
	private void «writerMethodName(m)»(java.nio.ByteBuffer buf) throws java.io.IOException {
		try {
			byte[] encoded = «getterName(m)»().getBytes("«encodingOf(m)»");
			«IF dimensionOf(m) == 0»
			buf.put(encoded);
			«IF findMemberDefiningSizeOf(m) == null»
			buf.put("\0".getBytes("«encodingOf(m)»"));
			«ENDIF»
			«ELSE»
			int len = Math.min(encoded.length, «dimensionOf(m)»);
			int pad = «dimensionOf(m)» - len;
			buf.put(encoded, 0, len);
			if(pad > 0) {
				for(int i = 0; i < pad; ++i) {
					buf.put((byte)0);	
				}
			}
			«ENDIF»
		} catch(java.io.UnsupportedEncodingException e) {
			throw new java.io.IOException(e);
		}
	}
	'''
	
	def encodingOf(StringMember m) {
		if(m.encoding != null) {
			return m.encoding;
		}
		
		return "UTF-8";
	}

	def packageDeclaration(Package pkg) '''
		«IF !pkg.name.empty»
			package «pkg.name»;
		«ENDIF»
	'''

	def fields(StructDeclaration struct) '''
		«FOR m : struct.members»
			«field(m)»
		«ENDFOR»
	'''

	def getters(StructDeclaration struct) '''
		«FOR m : struct.members»
			«getter(m)»
		«ENDFOR»
	'''

	def setters(StructDeclaration struct) '''
		«FOR m : struct.nonTransientMembers()»
			«setter(m)»
		«ENDFOR»
	'''

	def field(Member m) '''
		«printComments(m)»
		private «attributeJavaType(m)» «attributeName(m)»;
	'''

	def getter(Member m) '''
		«printComments(m)»
		public «attributeJavaType(m)» «getterName(m)»() {
			return this.«attributeName(m)»;
		}
	'''

	def setter(Member m) '''
		«printComments(m)»
		public void «setterName(m)»(«attributeJavaType(m)» «attributeName(m)») {
			this.«attributeName(m)» = «attributeName(m)»;
		}
	'''

	def attributeJavaType(Member m) {
		val nativeType = nativeTypeName(m)
		val javaType = native2JavaType(nativeType)

		if (isArray(m)) {
			if(m instanceof IntegerMember) {
				if(m.typename.equals("uint8_t") || m.typename.equals("int8_t")) {
					return "java.nio.ByteBuffer";
				}
			}
			if(m instanceof StringMember) {
				return javaType
			}
			return "java.util.ArrayList<" + box(javaType) + ">";
		} else {
			return javaType
		}
	}

	def box(String type) {
		switch (type) {
			case "byte": "Byte"
			case "short": "Short"
			case "int": "Integer"
			case "long": "Long"
			case "float": "Float"
			case "double": "Double"
			case "boolean": "Boolean"
			default: type
		}
	}

	def unbox(String type) {
		switch (type) {
			case "Short": "short"
			case "Int": "int"
			case "Long": "long"
			case "Float": "float"
			case "Double": "double"
			default: type
		}
	}

	def nativeTypeName(Member m) {
		switch (m) {
			ComplexTypeMember: javaType(m.type)
			IntegerMember: m.typename
			FloatMember: m.typename
			StringMember: m.typename
			default: throw new RuntimeException("Unsupported member type: " + m)
		}
	}

	def native2JavaType(String type) {
		switch (type) {
			case "uint8_t": "int"
			case "int8_t": "int"
			case "uint16_t": "int"
			case "int16_t": "int"
			case "int32_t": "int"
			case "uint32_t": "int"
			case "int64_t": "long"
			case "uint64_t": "long"
			case "char": "String"
			case "bool": "boolean"
			default: type
		}
	}

	def javaType(ComplexTypeDeclaration type) {
		val pkg = type.eContainer as Package
		if (pkg != null && !pkg.name.empty) {
			return pkg.name + "." + type.name
		}
		return type.name
	}
	
	def boolean isFixedSize(StructDeclaration struct) {
		for(Member m : struct.members) {
			if(!m.isFixedSize()) {
				return false;
			}
			if(m instanceof IntegerMember) {
				if(m.sizeofThis) {
					return false;
				}
			}
		}
		return true;
	}
	
	def boolean isFixedSize(ComplexTypeDeclaration typeDecl) {
		if(typeDecl instanceof StructDeclaration) {
			return isFixedSize(typeDecl)
		}
		// for enums always true
		return true;
	}
	
	def boolean isFixedSize(Member m) {
		if(m.isArray()) {
			if(m.array.dimension == 0) {
				return false;
			}
		}
		
		if(m instanceof ComplexTypeMember) {
			return isFixedSize(m.type);
		}
		return true;
	}
	
	def computeFixedSizeOf(StructDeclaration struct) {
		var size = 0 as long;
		for(Member m : struct.members) {
			if(m.isArray()) {
				size += computeFixedSizeOf(m) * dimensionOf(m);
			} else {
				size += computeFixedSizeOf(m);				
			}
		}
		return size;
	}
	
	def long computeFixedSizeOf(Member m)  {
		switch(m) {
			IntegerMember case m.typename == 'uint8_t': return 1
			IntegerMember case m.typename == 'int8_t': return 1
			IntegerMember case m.typename == 'uint16_t': return 2
			IntegerMember case m.typename == 'int16_t': return 2
			IntegerMember case m.typename == 'uint32_t': return 4
			IntegerMember case m.typename == 'int32_t': return 4
			IntegerMember case m.typename == 'uint64_t': return 8
			IntegerMember case m.typename == 'int64_t': return 8
			FloatMember case m.typename == 'float': return 4
			FloatMember case m.typename == 'double': return 8
			StringMember: return 1 // a char
			ComplexTypeMember: return computeFixedSizeOf(m.type)
			default: throw new RuntimeException("Unexpected member type: " + m)
		}
	}
	
	def long computeFixedSizeOf(ComplexTypeDeclaration typeDecl) {
		if(typeDecl instanceof StructDeclaration) {
			return computeFixedSizeOf(typeDecl)
		} else {
			return computeFixedSizeOf(typeDecl as EnumDeclaration)
		}
	}
	
	def long computeFixedSizeOf(EnumDeclaration enumDecl) {
		switch(enumDecl.typename) {
			case 'int8_t': return 1
			case 'uint8_t': return 1
			case 'int16_t': return 2
			case 'uint16_t': return 2
			case 'int32_t': return 4
			case 'uint32_t': return 4
			default: return 0
		}
	}
}
