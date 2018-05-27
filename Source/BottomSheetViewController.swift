/*********
MIT License

Copyright (c) 2018 Iury Painelli

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
**********/

import UIKit

class BottomSheetViewController: UIViewController {
    var topConstraint: NSLayoutConstraint?
    var sheetHeight: CGFloat = 0
    var peekHeight: CGFloat = 100
    var stopPositions: [CGFloat] = []
    var currentPosition = 0
    var startPanTranslation: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPanGestures()
    }
    
    
    private func setupPanGestures(){
        let panGesture = UIPanGestureRecognizer.init(target: self, action:#selector(self.panGesture))
        self.view.addGestureRecognizer(panGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let superview = view.superview {
            attachBottomSheet(superView: superview)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sheetHeight = self.view.frame.height
        stopPositions = [peekHeight, sheetHeight]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentAnimated()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func attachBottomSheet(superView: UIView) {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        topConstraint = self.view.topAnchor.constraint(equalTo: superView.bottomAnchor)
        topConstraint?.isActive = true
    }
    
    func presentAnimated() {
        self.topConstraint?.constant = -peekHeight
        UIView.animate(withDuration: 0.3) {
            self.view.superview?.layoutIfNeeded()
        }
    }
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        guard let topConstraint = self.topConstraint else {
            return
        }
        let translation = recognizer.translation(in: self.view)
        let finalTranslation = translation.y + topConstraint.constant
        let absFinalTranslation = abs(finalTranslation)
        switch recognizer.state {
        case .began:
            startPanTranslation = absFinalTranslation
        case .changed:
            //sheet position should stay between its height and peekHeight
            if absFinalTranslation <= sheetHeight && absFinalTranslation >= peekHeight {
                topConstraint.constant = finalTranslation
            }
        case .ended:
            let translationDelta = abs(absFinalTranslation - startPanTranslation)
            if abs(recognizer.velocity(in: self.view).y) > 100 && translationDelta < 50 && translationDelta > 0 {
                if currentPosition < stopPositions.count - 1 {
                    currentPosition = currentPosition + 1
                    topConstraint.constant = stopPositions[currentPosition] * (-1)
                } else if currentPosition > 0{
                    currentPosition = currentPosition - 1
                    topConstraint.constant = stopPositions[currentPosition] * (-1)
                }
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.superview?.layoutIfNeeded()
                })
            } else {
                topConstraint.constant = closestStopToPosition(position: absFinalTranslation)
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.superview?.layoutIfNeeded()
                })
            }
            
        default:
            break
        }
        recognizer.setTranslation(CGPoint(), in: self.view)
    }
    
    func closestStopToPosition(position: CGFloat) -> CGFloat {
        let closest = stopPositions.enumerated().min(by: { abs($0.1 - position) < abs($1.1 - position) })
        if let closestValue = closest {
            currentPosition = closestValue.offset
            return closestValue.element * (-1)
        }
        currentPosition = 0
        return peekHeight * (-1)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
