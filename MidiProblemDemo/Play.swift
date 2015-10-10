//
//  Playback.swift
//  TheoryDrills
//
//  Created by Samuel Goodwin on 7/10/15.
//  Copyright © 2015 Roundwall Software. All rights reserved.
//

import AVFoundation
import AudioToolbox

typealias Notes = [Note]

struct Note {
    let name: String
    let value: UInt8
}

class MidiEngine {
    private var graph = AUGraph()
    private var samplerUnit = AudioUnit()
    private var ioUnit = AudioUnit()
    
    init?() {
        guard NewAUGraph(&graph) == noErr else {
            return nil
        }
        
        var sampler = AUNode()
        var description = AudioComponentDescription(componentType: kAudioUnitType_MusicDevice, componentSubType: kAudioUnitSubType_Sampler, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
        
        guard AUGraphAddNode(graph, &description, &sampler) == noErr else {
            return nil
        }
        
        var ioNode = AUNode()
        var ioUnitDescription = AudioComponentDescription(componentType: kAudioUnitType_Output, componentSubType: kAudioUnitSubType_RemoteIO, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
        guard AUGraphAddNode(graph, &ioUnitDescription, &ioNode) == noErr else {
            return nil
        }
        
        guard AUGraphOpen(graph) == noErr else {
            return nil
        }
        
        guard AUGraphNodeInfo(graph, sampler, nil, &samplerUnit) == noErr else {
            return nil
        }
        
        guard AUGraphNodeInfo(graph, ioNode, nil, &ioUnit) == noErr else {
            return
        }
        
        let ioUnitOutputElement: AudioUnitElement = 0
        let samplerOutputElement: AudioUnitElement = 0
        
        guard AUGraphConnectNodeInput(graph, sampler, samplerOutputElement, ioNode, ioUnitOutputElement) == noErr else {
            return nil
        }
        
        var isInitialized: DarwinBoolean = false
        AUGraphIsInitialized(graph, &isInitialized)
        if !isInitialized {
            guard AUGraphInitialize(graph) == noErr else {
                return nil
            }
        }
        
        var isRunning: DarwinBoolean = false
        AUGraphIsRunning(graph, &isRunning)
        if !isRunning {
            guard AUGraphStart(graph) == noErr else {
                return nil
            }
        }
        
        let url = NSBundle.mainBundle().URLForResource("GeneralUser_GS_SoftSynth", withExtension: "sf2")!
        var instrumentData = AUSamplerInstrumentData(fileURL: Unmanaged.passUnretained(url), instrumentType: UInt8(kInstrumentType_SF2Preset), bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: 0, presetID: 0)
        
        guard AudioUnitSetProperty(samplerUnit, kAUSamplerProperty_LoadInstrument, kAudioUnitScope_Global, 0, &instrumentData, UInt32(sizeof(AUSamplerInstrumentData))) == noErr else {
            return nil
        }
    }
    
    func noteOn(note: Note) {
        let noteCommand = UInt32(0x90)
        
        guard MusicDeviceMIDIEvent(samplerUnit, noteCommand, UInt32(note.value), 100, 0) == noErr else {
            print("Failed to start playing note: \(note.name)")
            return
        }
    }
    
    func noteOff(note: Note) {
        let noteCommand = UInt32(0x80)
            
        guard MusicDeviceMIDIEvent(samplerUnit, noteCommand, UInt32(note.value), 100, 0) == noErr else {
            print("Failed to start playing note: \(note.name)")
            return
        }
    }
}
