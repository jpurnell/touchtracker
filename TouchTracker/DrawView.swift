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
	var selectedLineIndex: Int? {
		didSet {
			if selectedLineIndex == nil {
				let menu = UIMenuController.shared
				menu.setMenuVisible(false, animated: true)
			}
		}
	}
	
	override var canBecomeFirstResponder: Bool {
		return true
	}
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
	//MARK: - Init
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.doubleTap(_:)))
		doubleTapRecognizer.numberOfTapsRequired = 2
		doubleTapRecognizer.delaysTouchesBegan = true
		addGestureRecognizer(doubleTapRecognizer)
		
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.tap(_:)))
		tapRecognizer.delaysTouchesBegan = true
		tapRecognizer.require(toFail: doubleTapRecognizer)
		addGestureRecognizer(tapRecognizer)
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
		
		if let index = selectedLineIndex {
			UIColor.green.setStroke()
			let selectedLine = finishedLines[index]
			stroke(selectedLine)
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
	
	//MARK: - Multitouch methods
	func doubleTap(_ gestureRecognizer: UIGestureRecognizer) {
		print("Recognized a double tap")
		
		selectedLineIndex = nil
		currentLines.removeAll()
		finishedLines.removeAll()
		setNeedsDisplay()
	}
	
	func tap(_ gestureRecognizer: UIGestureRecognizer) {
		print("Recognized a tap")
		
		let point = gestureRecognizer.location(in: self)
		selectedLineIndex = indexOfLine(at: point)
		
		// Grab the menu controller
		let menu = UIMenuController.shared
		
		if selectedLineIndex != nil {
			
			// Make DrawView the target of menu item action messages
			becomeFirstResponder()
			
			// Create a new "Delete" UIMenuItem
			let deleteItem = UIMenuItem(title: "Delete", action: #selector(DrawView.deleteLine(_:)))
			menu.menuItems = [deleteItem]
			
			// Tell the menu where it shoudl come from and show it
			let targetRect = CGRect(x: point.x, y: point.y, width: 2, height: 2)
			menu.setTargetRect(targetRect, in: self)
			menu.setMenuVisible(true, animated: true)
		}
		
		setNeedsDisplay()
	}
	
	func indexOfLine(at point: CGPoint) -> Int? {
		// Find a line close to the point
		for (index, line) in finishedLines.enumerated() {
			let begin = line.begin
			let end = line.end
			
			//Check a few points on the line
			for t in stride(from: CGFloat(0), to: 1.0, by: 0.05) {
				let x = begin.x + ((end.x - begin.x) * t)
				let y = begin.y + ((end.y - begin.y) * t)
				
				// If the tapped point is within 20 points, lets return that line
					if hypot(x - point.x, y - point.y) < 20.0 {
					return index
				}
			}
		}
		
		// If nothing is close enough to the tapped point, then do not selet a line
		return nil
	}
	
	func deleteLine(_ sender: UIMenuController) {
		// Remove the selected line from the list of finishedLines
		if let index = selectedLineIndex{
			finishedLines.remove(at: index)
			selectedLineIndex = nil
			
			// Redraw everything
			setNeedsDisplay()
		}
	}
}
