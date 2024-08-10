//
//  BinaryIntExt.swift
//  SwPSSH
//
//  Created by developer on 18.07.2024.
//

///Bytes view representation for binary integer values
protocol BinaryIntegerByteView {
    ///Big-Endian bytes view
    var beBytes: [UInt8] {
         get
    }
    
    ///Little-Endian bytes view
    var leBytes: [UInt8] {
        get
    }
}

extension UInt64: BinaryIntegerByteView {
    var beBytes: [UInt8] {
        get {
            return leBytes.reversed()
        }
    }
    
    var leBytes: [UInt8] {
        get {
            return PSSHBinaryUtil.getLEndianBytes(self)
        }
    }
}

extension UInt32: BinaryIntegerByteView {
    var beBytes: [UInt8] {
        get {
            return leBytes.reversed()
        }
    }
    
    var leBytes: [UInt8] {
        get {
            return PSSHBinaryUtil.getLEndianBytes(self)
        }
    }
}

extension UInt16: BinaryIntegerByteView {
    var beBytes: [UInt8] {
        get {
            return leBytes.reversed()
        }
    }
    
    var leBytes: [UInt8] {
        get {
            return PSSHBinaryUtil.getLEndianBytes(self)
        }
    }
}

extension UInt8: BinaryIntegerByteView {
    var beBytes: [UInt8] {
        get {
            return [self]
        }
    }
    
    var leBytes: [UInt8] {
        get {
            return beBytes
        }
    }
}

extension Int8: BinaryIntegerByteView {
    var beBytes: [UInt8] {
        get {
            let uVal = UInt8(bitPattern: self)
            return [uVal]
        }
    }
    
    var leBytes: [UInt8] {
        get {
            return beBytes
        }
    }
}

extension Int16: BinaryIntegerByteView {
    var beBytes: [UInt8] {
        get {
            return leBytes.reversed()
        }
    }
    
    var leBytes: [UInt8] {
        get {
            let uVal = UInt16(bitPattern: self)
            return uVal.leBytes
        }
    }
}

extension Int32: BinaryIntegerByteView {
    var beBytes: [UInt8] {
        get {
            return leBytes.reversed()
        }
    }
    
    var leBytes: [UInt8] {
        get {
            let uVal = UInt32(bitPattern: self)
            return uVal.leBytes
        }
    }
}

extension Int64: BinaryIntegerByteView {
    var beBytes: [UInt8] {
        get {
            return leBytes.reversed()
        }
    }
    
    var leBytes: [UInt8] {
        get {
            let uVal = UInt64(bitPattern: self)
            return uVal.leBytes
        }
    }
}
