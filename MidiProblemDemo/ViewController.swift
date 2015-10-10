//
//  ViewController.swift
//  MidiProblemDemo
//
//  Created by Samuel Goodwin on 10/10/15.
//  Copyright © 2015 Roundwall Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let engine = MidiEngine()
    let note = Note(name: "C", value: 60)

    @IBAction func play(sender: UIButton) {
        engine?.noteOn(note)
    }
    
    @IBAction func stop(sender: UIButton) {
        engine?.noteOff(note)
    }
}

