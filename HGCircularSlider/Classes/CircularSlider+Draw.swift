//
//  CircularSlider+Draw.swift
//  Pods
//
//  Created by Hamza Ghazouani on 21/10/2016.
//
//

import UIKit

extension CircularSlider {
    
    /**
     Draw arc with stroke mode (Stroke) or Disk (Fill) or both (FillStroke) mode
     FillStroke used by default
     
     - parameter arc:           the arc coordinates (origin, radius, start angle, end angle)
     - parameter lineWidth:     the with of the circle line (optional) by default 2px
     - parameter mode:          the mode of the path drawing (optional) by default FillStroke
     - parameter context:       the context
     
     */
    internal static func drawArc(withArc arc: Arc, lineWidth: CGFloat = 2, mode: CGPathDrawingMode = .fillStroke, inContext context: CGContext) {
        
        let circle = arc.circle
        let origin = circle.origin
        
        UIGraphicsPushContext(context)
        context.beginPath()
        
        context.setLineWidth(lineWidth)
        context.setLineCap(CGLineCap.round)
        context.addArc(center: origin, radius: circle.radius, startAngle: arc.startAngle, endAngle: arc.endAngle, clockwise: false)
        context.move(to: CGPoint(x: origin.x, y: origin.y))
        context.drawPath(using: mode)
        
        UIGraphicsPopContext()
    }
    
    /**
     Draw disk using arc coordinates
     
     - parameter arc:     the arc coordinates (origin, radius, start angle, end angle)
     - parameter context: the context
     */
    internal static func drawDisk(withArc arc: Arc, inContext context: CGContext) {

        let circle = arc.circle
        let origin = circle.origin

        UIGraphicsPushContext(context)
        context.beginPath()

        context.setLineWidth(0)
        context.addArc(center: origin, radius: circle.radius, startAngle: arc.startAngle, endAngle: arc.endAngle, clockwise: false)
        context.addLine(to: CGPoint(x: origin.x, y: origin.y))
        context.drawPath(using: .fill)

        UIGraphicsPopContext()
    }

    // MARK: drawing instance methods

    /// Draw the circular slider
    internal func drawCircularSlider(inContext context: CGContext) {
        diskColor.setFill()
        trackColor.setStroke()

        let circle = Circle(origin: bounds.center, radius: self.radius)
        let sliderArc = Arc(circle: circle, startAngle: CircularSliderHelper.circleMinValue, endAngle: CircularSliderHelper.circleMaxValue)
        CircularSlider.drawArc(withArc: sliderArc, lineWidth: backtrackLineWidth, inContext: context)
    }

    /// draw Filled arc between start an end angles
    internal func drawFilledArc(fromAngle startAngle: CGFloat, toAngle endAngle: CGFloat, inContext context: CGContext) {
        diskFillColor.setFill()
        trackFillColor.setStroke()

        let circle = Circle(origin: bounds.center, radius: self.radius)
        let arc = Arc(circle: circle, startAngle: startAngle, endAngle: endAngle)
        
        // fill Arc
        CircularSlider.drawDisk(withArc: arc, inContext: context)
        // stroke Arc
        CircularSlider.drawArc(withArc: arc, lineWidth: lineWidth, mode: .stroke, inContext: context)
    }

    internal func drawShadowArc(fromAngle startAngle: CGFloat, toAngle endAngle: CGFloat, inContext context: CGContext) {
        trackShadowColor.setStroke()

        let origin = CGPoint(x: bounds.center.x + trackShadowOffset.x, y: bounds.center.y + trackShadowOffset.y)
        let circle = Circle(origin: origin, radius: self.radius)
        let arc = Arc(circle: circle, startAngle: startAngle, endAngle: endAngle)

        // stroke Arc
        CircularSlider.drawArc(withArc: arc, lineWidth: lineWidth, mode: .stroke, inContext: context)
    }

    /**
     Draw the thumb and return the coordinates of its center
     
     - parameter angle:   the angle of the point in the main circle
     - parameter context: the context
     
     - returns: return the origin point of the thumb
     */
    @discardableResult
    internal func drawThumb(withAngle angle: CGFloat, inContext context: CGContext) -> CGPoint {
        let circle = Circle(origin: bounds.center, radius: self.radius)
        let thumbOrigin = CircularSliderHelper.endPoint(fromCircle: circle, angle: angle)
        let thumbCircle = Circle(origin: thumbOrigin, radius: thumbRadius)
        let thumbArc = Arc(circle: thumbCircle, startAngle: CircularSliderHelper.circleMinValue, endAngle: CircularSliderHelper.circleMaxValue)

        CircularSlider.drawArc(withArc: thumbArc, lineWidth: thumbLineWidth, inContext: context)
        return thumbOrigin
    }

    /**
     Draw thumb using image and return the coordinates of its center

     - parameter image:   the image of the thumb
     - parameter angle:   the angle of the point in the main circle
     - parameter context: the context
     
     - returns: return the origin point of the thumb
     */
    @discardableResult
    internal func drawThumb(withImage image: UIImage, angle: CGFloat, inContext context: CGContext) -> CGPoint {
        UIGraphicsPushContext(context)
        context.beginPath()
        let image = image.imageRotatedByDegrees(degrees: angle * 57.2958 + 90)
        let circle = Circle(origin: bounds.center, radius: self.radius)
        let thumbOrigin = CircularSliderHelper.endPoint(fromCircle: circle, angle: angle)
        let imageSize = image.size
        let imageFrame = CGRect(x: thumbOrigin.x - (imageSize.width / 2), y: thumbOrigin.y - (imageSize.height / 2), width: imageSize.width, height: imageSize.height)
        image.draw(in: imageFrame)
        UIGraphicsPopContext()

        return thumbOrigin
    }
}

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, UIScreen.main.scale)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
