//
//  Quantis.swift
//  
//
//  Created by Vladimir Young on 3/19/22.
//
// QuantisDevice:
// 1 = QUANTIS_PCI_DEVICE
// 2 = QUANTIS_USB_DEVICE

import Foundation
import СQuantis

public var Quantis: QuantisFunctions {
    return.init()
}

public typealias QuantisDevice = QuantisDeviceType

public final class QuantisFunctions {
    
    public func quantisCount(device: UInt32) -> Int32 {
        let count = QuantisCount(QuantisDevice(device))
        return count
    }
    
    public func printAllCards() {
        
        func printInfo(device: UInt32) {
            let driverVersion = QuantisGetDriverVersion(QuantisDevice(device))
            let deviceCount = QuantisCount(QuantisDevice(device))
            
            if driverVersion < 0.0 {
                print("Error while getting driver version.\n")
            }
            print(" Using driver version: \(driverVersion)\n")
            
            print(" Found card(s): \(deviceCount)\n")
            
            if deviceCount > 0 {
                for i in 1 ... deviceCount {
                    let deviceNumber = UInt32(i-1)
                    let boardVersion = QuantisGetBoardVersion(QuantisDevice(device), UInt32(deviceNumber))
                    let serialNumber = String(cString: (QuantisGetSerialNumber(QuantisDevice(device), UInt32(deviceNumber))))
                    let manufacturer = String(cString: (QuantisGetManufacturer(QuantisDevice(device), UInt32(deviceNumber))))
                    
                    print("     - Details for device #\(deviceNumber)")
                    print("      core version: \(boardVersion)")
                    print("      serial number: \(serialNumber)")
                    print("      manufacturer: \(manufacturer)")
                }
            }
        }
        
        print("""
                                                     '`.
                          .l<>>!:'               .;>~<>+<'
                         .__^`^;>+<:           ^>_>,'  .-_
                         '[:      :<_!'      ^<_l.      ![.
                        `i]-~I      `i-i'  '<-I         ~-
                       ']]]]]]<       '>-;;-i.         .]!
                       .+]]]]]l         ;[[i           i].
                         ,l>[;         ;_;^+>.        `[I
                            ~?^^,,:;;;<[+Il![]l:;;:,"`-_
                     `,I!><<<-]>!!lI![+,,:::";][lI!!!]]<<<>i;I><i,
                 ^l<~<iI,^'. .++   `-i        .~+.  I]^ .'`I[]]]]]>
               `<_l".         ._-.,[!           i[,I[,     .-]]]]]__:
               +]               >-];             :[],       .I>>l^ i['
               `~+l^            ,][,             l]]!           .,<_;
                 "!<~>!;,`.    "]:^-!           i-''?i   .`^:l>~~>;.
                    .^:li><<<>i]]I;i]_,",,,,,,,+[iIl~]~><<<>!;"'
                           .'`]_":;;;i]?ll!!I+]<;;;:":[!
                             l]'      ^~<'  l-;       I[^
                            '[l         l-i~+`         +-
                            i]           <]]I          `[I
                            ?>    `i+_~!_<.`~_I.        +_
                           .[I   .?]]]]]_    ^<_i^      i[
                            -+   '-]]]]]l      'l~~!,`'"]<
                            `+~i<~>;Il;`          ^Ii<<<I
                              '^` \n
            Swift Quantis CLI - Displaying devices info:\n
            """)
        
        print(" Searching for PCI-E devices...")
        printInfo(device: 1)
        
        print("-----------------")
        print(" Searching for USB devices...")
        printInfo(device: 2)
    }
    
    public func roll(deviceType: QuantisDevice, deviceNumber: UInt32) throws -> Int32 {
        let min: Int32 = 1
        let max: Int32 = 100
        let pointer = UnsafeMutablePointer<Int32>.allocate(capacity: Int(max))
        let deviceHandle = QuantisReadScaledInt(deviceType, deviceNumber, pointer, min, max)
        
        defer {
            pointer.deinitialize(count: Int(max))
            pointer.deallocate()
        }
        
        let result = pointer.pointee
        
        // Check if device is in working state.
        if deviceHandle != 0 {
            throw QuantisError.deviceError
        }
        
        // Check if result is correct.
        if result < min || result > max {
            throw QuantisError.noResult
        }
        return result
    }
    
    public func jackpot(deviceType: QuantisDevice, deviceNumber: UInt32) throws -> Double {
        let min: Double = 0.01
        let max: Double = 100.00
        let pointer = UnsafeMutablePointer<Double>.allocate(capacity: Int(max))
        let deviceHandle = QuantisReadScaledDouble(deviceType, deviceNumber, pointer, min, max)
        
        defer {
            pointer.deinitialize(count: Int(max))
            pointer.deallocate()
        }
        
        let result = pointer.pointee
        
        if deviceHandle != 0 {
            throw QuantisError.deviceError
        }
        
        if result < min || result > max {
            throw QuantisError.noResult
        }
        return Double(result).round(to: 2)
    }
    
    public func coinflip(deviceType: QuantisDevice, deviceNumber: UInt32) throws -> Int32 {
        let min: Int32 = 1
        let max: Int32 = 2
        let pointer = UnsafeMutablePointer<Int32>.allocate(capacity: Int(max))
        let deviceHandle = QuantisReadScaledInt(deviceType, deviceNumber, pointer, min, max)
        
        defer {
            pointer.deinitialize(count: Int(max))
            pointer.deallocate()
        }
        
        let result = pointer.pointee
        
        if deviceHandle != 0 {
            throw QuantisError.deviceError
        }
        
        if result < min || result > max {
            throw QuantisError.noResult
        }
        return result
    }
    
    public func wheel(deviceType: QuantisDevice, deviceNumber: UInt32) throws -> Double {
        let min: Double = 1.00
        let max: Double = 25.99
        let pointer = UnsafeMutablePointer<Double>.allocate(capacity: Int(max))
        
        let deviceHandle = QuantisReadScaledDouble(deviceType, deviceNumber, pointer, min, max)
        
        defer {
            pointer.deinitialize(count: Int(max))
            pointer.deallocate()
        }
        
        let result = pointer.pointee
        
        if deviceHandle != 0 {
            throw QuantisError.deviceError
        }
        
        if result < min || result > max {
            throw QuantisError.noResult
        }
        return Double(result).round(to: 2)
    }
    
    public func quantisReadScaledInt(deviceType: QuantisDevice, deviceNumber: UInt32, min: Int32, max: Int32) throws -> Int32 {
        let pointer = UnsafeMutablePointer<Int32>.allocate(capacity: Int(max))
        
        let deviceHandle = QuantisReadScaledInt(deviceType, deviceNumber, pointer, min, max)
        defer {
            pointer.deinitialize(count: Int(max))
            pointer.deallocate()
        }
        
        // If not check for min > max device gets in error state and stop working.
        if min > max {
            throw QuantisError.invalidParameters
        }
        
        let result = pointer.pointee
        
        if deviceHandle != 0 {
            throw QuantisError.deviceError
        }
        
        if result < min || result > max {
            throw QuantisError.noResult
        }
        return result
    }
    
    public func quantisReadScaledDouble(deviceType: QuantisDevice, deviceNumber: UInt32, min: Double, max: Double) throws -> Double {
        let pointer = UnsafeMutablePointer<Double>.allocate(capacity: Int(max))
        
        let deviceHandle = QuantisReadScaledDouble(deviceType, deviceNumber, pointer, min, max)
        defer {
            pointer.deinitialize(count: Int(max))
            pointer.deallocate()
        }
        
        if min > max {
            throw QuantisError.invalidParameters
        }
        
        let result = pointer.pointee
        
        if deviceHandle != 0 {
            throw QuantisError.deviceError
        }
        
        if result < min || result > max {
            throw QuantisError.noResult
        }
        return Double(result).round(to: 2)
    }
}
