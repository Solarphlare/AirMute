import IOBluetooth

enum AirPodsModel: UInt16 {
    case gen1 = 0x2002
    case gen2 = 0x200F
    case gen3 = 0x2013
    case gen4 = 0x201B
    case max1 = 0x200A
    case max1UsbC = 0x201F
    case max2 = 0x202D
    case pro1 = 0x200E
    case pro2 = 0x2014
    case pro2UsbC = 0x2024
    case pro3 = 0x202F
}

let unsupportedRegularAirPodsModels: Set<AirPodsModel> = [.gen1, .gen2]
fileprivate let regularAirPodsModels: Set<AirPodsModel> = [.gen3, .gen4]
fileprivate let airpodsMaxModels: Set<AirPodsModel> = [.max1, .max1UsbC, .max2]
fileprivate let airpodsProModels: Set<AirPodsModel> = [.pro1, .pro2, .pro2UsbC, .pro3]

enum AirPodsVariant: String {
    case unsupportedBase = "Unsupported Base" // Gen 1, Gen 2
    case base = "Base" // Gen 3, Gen 4
    case pro = "Pro"
    case max = "Max"
}

struct ConnectedAirPods {
    var variants = Set<AirPodsVariant>()
    var models = Set<AirPodsModel>()
}

private final class SDPQuery: NSObject {
    private var continuation: CheckedContinuation<Bool, Never>?

    func perform(on device: IOBluetoothDevice) async -> Bool {
        await withCheckedContinuation { continuation in
            self.continuation = continuation

            let status = device.performSDPQuery(self)
            if status != kIOReturnSuccess {
                complete(with: status)
            }
        }
    }

    @objc func sdpQueryComplete(_ device: IOBluetoothDevice, status: IOReturn) {
        complete(with: status)
    }

    private func complete(with status: IOReturn) {
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(returning: status == kIOReturnSuccess)
    }
}

func getConnectedAirPods() async -> ConnectedAirPods {
    guard let pairedDevices = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] else { return ConnectedAirPods() }
    var connectedAirPods = ConnectedAirPods()
    
    var appleAudioDevices = [String]()

    for device in pairedDevices where device.isConnected() {
        guard
            await SDPQuery().perform(on: device),
            let record = device.getServiceRecord(for: IOBluetoothSDPUUID(uuid16: 0x1200)),
            let vendorID = record.getAttributeDataElement(0x0201)?.getNumberValue()?.uint16Value,
            vendorID == 0x004C,
            device.isHandsFreeDevice,
            let productID = record.getAttributeDataElement(0x0202)?.getNumberValue()?.uint16Value
        else { continue }

        guard let model = AirPodsModel(rawValue: productID) else {
            appleAudioDevices.append("0x\(String(productID, radix: 16))")
            continue
        }
        
        appleAudioDevices.append("0x\(String(productID, radix: 16)) (\(String(describing: model)))")
        connectedAirPods.models.insert(model)
        
        if unsupportedRegularAirPodsModels.contains(model) { connectedAirPods.variants.insert(.unsupportedBase) }
        else if regularAirPodsModels.contains(model) { connectedAirPods.variants.insert(.base) }
        else if airpodsMaxModels.contains(model) { connectedAirPods.variants.insert(.max) }
        else if airpodsProModels.contains(model) { connectedAirPods.variants.insert(.pro) }
    }

    logger.info("[BluetoothController] Refreshed list of connected Apple audio devices: \(appleAudioDevices.joined(separator: ", "))")
    return connectedAirPods
}
