//
//  ViewController.swift
//  wordScramble
//
//  Created by Darren on 6/13/17.
//  Copyright © 2017 Darren. All rights reserved.
//

import UIKit
// this kit gives you methods such as shuffling an array.
import GameplayKit

class TableViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let allWordsPath = Bundle.main.path(forResource: "start", ofType: "txt"){
            // converts all words in the files into string.
            if let startWords = try? String(contentsOfFile: allWordsPath){
                // cuts a string and make it into an arry bases on the separator provided
                allWords = startWords.components(separatedBy: "\n")
                
            }else{
                
                allWords = ["Cake"]
            }
            
            startGame()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Make Word", style: .plain, target: self, action: #selector (makeWord))
    }

    func startGame(){
        // shuffles the array, u shud remember this ...
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        title = allWords[0]
        usedWords.removeAll(keepingCapacity: true)
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
        
    }
  
    
    func makeWord() {
        // sets up the alert title and stuff
        let ac = UIAlertController(title: "Add Word", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        
       
        //adds a submit button
//        the unowned part is a capture list which tells the ARC(memory boss) that everything that
//        the closure references is weak. This is important because ARC can't deallocate strong
//        refences. Closures captures everything so when you use something it establishes a
//        strong reference to the things you use; so it can  be used inside the closure but
//        it creates a memory leak even when you close the application if it has a strong reference
//        since ARC can only
        let submit = UIAlertAction(title: "Submit", style: .default) { [unowned self,ac]
            
            (action: UIAlertAction!) in
            let answer = ac.textFields?[0]
            self.submit(answer: (answer?.text)!)
            
            }
       
        ac.addAction(submit)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac,animated: true)
    }
    
    
  
    func submit(answer: String){
        let lowerAnswer = answer.lowercased()
        let errorTitle: String
        let errorMessage: String
        
        // By default, all these if statements will run IF the methods returns true
        if lowerAnswer == title!.lowercased(){
            errorTitle = "Can't be same as host word"
            errorMessage = "Be mroe creative"
        } else {
        if isPossiable(word: lowerAnswer){
            if isOriginal(word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    //adds the word into the array
                    usedWords.insert(lowerAnswer, at: 0)
                    // since the cellForRow method already adds what's inside the usedWords
                    // array, the below is just reloading and positioning the new added
                    // words. You can also do tableView.reload() but it's too much memory.
                    let indexPath = IndexPath(row: 0, section: 0 )
                    
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                    
                } else {
                    errorTitle = "Word not reconigized"
                    errorMessage = "Use letters from the title only"
                    

                }
            } else {
                errorTitle = "Invalid Word"
                errorMessage = "Word already exist"
            }
        } else {
            errorTitle = "Spelling Word"
            errorMessage = "You can't spell that word from \(String(describing: title!))"
            }
        }
        
        let errorAc = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        errorAc.addAction(UIAlertAction(title: "Ok", style: .default))
        present(errorAc,animated: true)

        
    }
    
    func isPossiable(word: String) -> Bool {
        var tempWord = title!.lowercased()
        for letters in word.characters{
            //searches through tempWord to see if the characters in letters exist in the tempWord
            // if it does it won't return a nil and the 'if' check will let it pass through
            if let possiable = tempWord.range(of: String(letters)){
                // keep in mind this is in a for loop which iliterates through the tempWord characters
                // so the below code removes the letter in the tempWord so they don't repeat the
                // same characters.
                tempWord.remove(at: possiable.lowerBound)
                
                
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        // this basically asks if usedWords contains the 'word', if it does it returns true,
        // but the '!' flips it so now it is returning the opposite of the original return.
        return !usedWords.contains(word)
    }
    
    func  isReal(word: String) -> Bool {
        // creates a UITextChecker class so we can use it's properties/methods
        let checker = UITextChecker()
        // creates a range so we can use it for the range of the method we are going to use later
        let textRange = NSMakeRange(0, word.utf16.count)
        let misSpelledRange = checker.rangeOfMisspelledWord(in: word, range: textRange, startingAt: 0, wrap: false, language: "en")
        // If there is a misSpelled word, swift will give us a location thus making the return
        // false. If there is no misSpelled words, then it will be equal to NSNotFound thus
        // making this call true.
        if word.utf16.count < 4 {
            return false
       }
        return misSpelledRange.location == NSNotFound
    }
}
