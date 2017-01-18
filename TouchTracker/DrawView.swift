//
//  DrawView.swift
//  TouchTracker
//
//  Created by Justin Purnell on 1/18/17.
//  Copyright © 2017 Justin Purnell. All rights reserved.
//

import Foundation
import UIKit

class DrawView: UIView {
	var currentLine: Line?
	var finishedLines = [Line]()

	func stroke(_ line: Line) {
		let path = UIBezierPath()
		path.lineWidth = 10
		path.lineCapStyle = .round
		
		path.move(to: line.begin)
		path.addLine(to: line.end)
		path.stroke()
	}

	override func draw(_ rect: CGRect) {
		// Draw finished lines in black
		UIColor.blue.setStroke()
		for line in finishedLines {
			stroke(line)
		}
		
		if let line = currentLine {
			// If there is a line currently being drawn, do it in red
			UIColor.red.setStroke()
			stroke(line)
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first!
		
		// Get location of the touch in the view's coordinate system
		let location = touch.location(in: self)
		
		currentLine = Line(begin: location, end: location)
		
		setNeedsDisplay()
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first!
		let location = touch.location(in: self)
		
		currentLine?.end = location
		setNeedsDisplay()
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if var line = currentLine {
			let touch = touches.first!
			let location = touch.location(in: self)
			line.end = location
			
			finishedLines.append(line)
		}
		
		currentLine = nil
		
		setNeedsDisplay()
	}
}
