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
	var currentLines = [NSValue:Line]()
	var finishedLines = [Line]()
	
	//MARK: – @IBInspectable
	@IBInspectable var finishedLineColor: UIColor = UIColor.blue {
		didSet {
			setNeedsDisplay()
		}
	}
	
	@IBInspectable var currentLineColor: UIColor = UIColor.red {
		didSet {
			setNeedsDisplay()
		}
	}
	
	@IBInspectable var lineThickness: CGFloat = 10 {
		didSet {
			setNeedsDisplay()
		}
	}
	
	
	//MARK: - Drawing

	func stroke(_ line: Line) {
		let path = UIBezierPath()
		path.lineWidth = lineThickness
		path.lineCapStyle = .round
		
		path.move(to: line.begin)
		path.addLine(to: line.end)
		path.stroke()
	}

	override func draw(_ rect: CGRect) {
		finishedLineColor.setStroke()
		for line in finishedLines {
			stroke(line)
		}
		
		currentLineColor.setStroke()
		for(_, line) in currentLines {
			stroke(line)
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		// Log statement to see the order of events
		print(#function)
		
		for touch in touches {
			let location = touch.location(in: self)
			
			let newLine = Line(begin: location, end: location)
			
			let key = NSValue(nonretainedObject: touch)
			currentLines[key] = newLine
		}
		setNeedsDisplay()
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		// Log statement to see the order of events
		print(#function)
		
		for touch in touches {
			let key = NSValue(nonretainedObject: touch)
			currentLines[key]?.end = touch.location(in: self)
		}
		setNeedsDisplay()
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		// Log statement to see the order of events
		print(#function)
		
		for touch in touches {
			let key = NSValue(nonretainedObject: touch)
			if var line = currentLines[key] {
				line.end = touch.location(in: self)
				
				finishedLines.append(line)
				currentLines.removeValue(forKey: key)
			}
		}
		setNeedsDisplay()
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		// Log statement to see the order of events
		print(#function)
		
		currentLines.removeAll()
		
		setNeedsDisplay()
	}
}
