//
//  ViewController.swift
//  Hangman
//
//  Created by LALIT JAGTAP on 7/19/18.
//  Copyright © 2018 LALIT JAGTAP. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController {

    var allWords = [String]()
    var usedLetters = [String] ()
    var wrongAnswers = 0
    var hiddenWord = ""
    var promptWord = ""
    var pressedButtons = [UIButton] ()

    @IBOutlet weak var showWord: UILabel!
    @IBOutlet weak var showUsedLetters: UILabel!
    @IBOutlet weak var showCountWrong: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "HangMan"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restartGame))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptCharToUser))
        
        
        // read all words from a "allwords.txt" file
        if let pathToAllWordsFile = Bundle.main.path(forResource: "allwords", ofType: "txt") {
            if let pathToAllWordsFile = try? String(contentsOfFile: pathToAllWordsFile) {
                allWords = pathToAllWordsFile.components(separatedBy: "\n")
            }
        } else {
            allWords = ["LALIT"]
        }
        
        restartGame()
    }
    
    @objc func restartGame(alert: UIAlertAction! = nil) {
        // select a random word from a allWords, by shuffling all words in array
        showUsedLetters.text = ""
        showCountWrong.text = ""
        showWord.text = ""
        promptWord = ""
        hiddenWord = ""
        wrongAnswers = 0

        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        usedLetters.removeAll(keepingCapacity: true)
        hiddenWord = allWords[0]
        
        print("hidden word selected is \(hiddenWord)")
        
        // prepare word for user with ? from hidden Word and show to user
        for _ in hiddenWord.indices {
            promptWord += "?"
        }

        showWord.text = promptWord
        
        // go thru pressedButtons by user
        for btn in pressedButtons {
            btn.backgroundColor = UIColor.clear
            btn.isEnabled = true
        }
    }
    
    @objc func promptCharToUser() {
        // prompt using alert dialog and based on user input call the submit action
        let ac = UIAlertController(title: "Enter letter", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac]
            (action: UIAlertAction) in
            let answer = ac.textFields![0]
            self.submit(charByUser: answer.text!)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(charByUser: String) {
        
        let userLetter = String(charByUser.first!)
        print ("user entered a letter \(userLetter)")
        
        // show used letters on screen
        usedLetters.append(userLetter)
        showUsedLetters.text =  usedLetters.joined(separator: " ")
        
        // check if the letter entered is present in the hiddenword
        if hiddenWord.contains(userLetter) {
            
            // update the promptWord and update the showWord
            for idx in hiddenWord.indices {
                if (hiddenWord[idx] == userLetter.first!) {
                    promptWord.remove(at: idx)
                    promptWord.insert(userLetter.first!, at: idx)
                }
            }
            showWord.text = promptWord
            
            // check if user won by checking if the hidden word matches the prompt word
            if promptWord == hiddenWord {
                print("you won by identifying correct hidden word as \(hiddenWord) same as \(promptWord)")
                // display alert dialog with RESTART btn
                
                let ac = UIAlertController(title: "Success", message: "Word matched to \(hiddenWord)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: restartGame))
                present(ac, animated: true)
                return
            }
            
        } else {
            // if not present than increment wrong answer count
            wrongAnswers += 1
            showCountWrong.text = String(wrongAnswers)
        }
        
        
        // if the wrongAnswer count is 7 than user loses display the message as "You lost. Try next word"
        if (wrongAnswers) == 7 {
            print ("You lost. Try next word.")
            
            let ac = UIAlertController(title: "Failure", message: "Correct word was \(hiddenWord)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: restartGame))
            present(ac, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
        letter present in hiddenWord than mark it with GREEN
        letter present NOT present in hiddenWord than mark it with RED
        add the btn to the list of pressed Btn Controls
        in restart method reset set the background color of all pressed Btn to clear
        if user gave 7 wrong ansers display alert message you lost. and display correct answer.
        if user gave correct anser than
     */
    
    @IBAction func letterPressed(_ sender: UIButton) {
        print("button pressed \(sender.titleLabel!)")
        
        pressedButtons.append(sender)
        
        if hiddenWord.contains(sender.currentTitle!) {
            sender.backgroundColor = UIColor.green
        } else {
            sender.backgroundColor = UIColor.red
        }
        sender.isEnabled = false
        
        submit(charByUser: sender.currentTitle!)
    }
    
}

