//
//  ViewController.m
//  Hangman
//
//  Created by Samuel Boyce on 1/13/16.
//  Copyright © 2016 Samuel Boyce. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UIButton *mainButton;

@property (weak, nonatomic) IBOutlet UIImageView *bodyImage;
@property (weak, nonatomic) IBOutlet UIImageView *leftLegImage;
@property (weak, nonatomic) IBOutlet UIImageView *rightLegImage;
@property (weak, nonatomic) IBOutlet UIImageView *rightArmImage;
@property (weak, nonatomic) IBOutlet UIImageView *leftArmImage;

@property (strong, nonatomic) NSArray *bodyParts;

@property (strong, nonatomic) NSArray *specialCharacters;

@property (weak, nonatomic) IBOutlet UILabel     *wordEnterLabel;
@property (weak, nonatomic) IBOutlet UITextField *wordEnterTextField;
@property (weak, nonatomic) IBOutlet UILabel     *eightOrLessLabel;
@property (weak, nonatomic) IBOutlet UILabel     *guessedLettersLabel;

@property (strong, nonatomic) NSString       *chosenWord;
@property (strong, nonatomic) NSMutableArray *chosenWordLetters;
@property (strong, nonatomic) NSMutableArray *chosenWordLettersLabels;
@property (strong, nonatomic) NSMutableArray *guessedLetters;

@property BOOL wordNeedsEntering;
@property BOOL gameOver;

@property NSUInteger guesses;
@property NSUInteger correctGuesses;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.wordEnterTextField.userInteractionEnabled = YES;
    
    //Initialize some of the properties:
    self.wordNeedsEntering = YES;
    self.gameOver = NO;
    self.guesses = 0;
    self.correctGuesses = 0;
    
    self.chosenWordLetters       = [[NSMutableArray alloc] init];
    self.chosenWordLettersLabels = [[NSMutableArray alloc] init];
    self.guessedLetters          = [[NSMutableArray alloc] init];
    
    self.bodyParts = @[self.bodyImage,
                       self.leftArmImage, self.leftLegImage,
                       self.rightArmImage, self.rightLegImage];
    
    self.specialCharacters = @[@"!", @"@", @"#", @"$", @"%", @"^", @"&", @"*", @"(", @")", @"_", @"-", @"+", @"=", @"{", @"}", @"[", @"]", @"|", @":", @";", @"<", @",", @">", @".", @"?", @"/", @"`", @"~"];
}

//Controls what happens when the button gets pressed
- (IBAction)buttonPressed:(UIButton *)sender
{
    //If a word has not yet been selected:
    if (self.wordNeedsEntering && !self.gameOver)
    {
        //Set the selected word
        self.chosenWord = [self.wordEnterTextField.text lowercaseString];
        
        //If the word is of the specified length:
        if ([self.chosenWord length] <= 8 && [self.chosenWord length] > 0)
        {
            //Put each letter in the word into an array
            for (NSUInteger i = 0; i < [self.chosenWord length]; i++)
            {
                NSString *character = [NSString stringWithFormat:@"%c", [self.chosenWord characterAtIndex:i]];
                if ([self.specialCharacters containsObject:character])
                {
                    self.wordEnterLabel.text = @"Please do not use special characters";
                    self.wordEnterLabel.textColor = [UIColor redColor];
                    self.wordEnterTextField.text = @"";
                    [self.chosenWordLetters removeAllObjects];
                    return;
                }
                [self.chosenWordLetters addObject:character];
            }
            //Reset the UI for guess input
            self.wordEnterLabel.text = @"Enter a 1-letter guess and press the button";
            self.wordEnterLabel.textColor = [UIColor blueColor];
            self.wordEnterTextField.text = @"";
            self.eightOrLessLabel.textColor = [UIColor clearColor];
            
            self.wordNeedsEntering = NO;
            
            [self drawWordLabels];
        }
        //If the word is over the specified length, draw the user's attention to the prompt
        else
        {
            self.eightOrLessLabel.textColor = [UIColor redColor];
        }
    }
    //If a word has been selected:
    else if (!self.wordNeedsEntering && !self.gameOver)
    {
        [self handleGuess];
    }
    //If the game is over
    else if (self.gameOver)
    {
        [self reset];
    }
    //Reset the text field each time the button is pressed
    self.wordEnterTextField.text = @"";
}

//Programatically add the labels that will represent the letters of the chosen word
- (void)drawWordLabels
{
    for (NSUInteger i = 0; i < [self.chosenWordLetters count]; i++)
    {
        //Create and initialize a label
        CGRect labelRect = CGRectMake(0 + (48 * i), 580, 40, 40);
        UILabel *thisLabel = [[UILabel alloc] initWithFrame:labelRect];
        
        //Handle the case where this character is a space
        if ([self.chosenWordLetters[i]  isEqualToString: @" "])
        {
            thisLabel.backgroundColor = [UIColor clearColor];
            self.correctGuesses++;
        }
        else
        {
            //Set the label properties
            thisLabel.text = @"?";
            thisLabel.textAlignment = NSTextAlignmentCenter;
            thisLabel.backgroundColor = [UIColor grayColor];
        }
        
        //Add the label to an array
        [self.chosenWordLettersLabels addObject:thisLabel];
        
        //Draw the label on the view
        [self.mainView addSubview:thisLabel];
    }
}

//What to do when the user guesses a letter
- (void)handleGuess
{
    //Grab the guess input
    NSString *guessLetter = [self.wordEnterTextField.text lowercaseString];
    
    if ([self.specialCharacters containsObject:guessLetter])
    {
        self.wordEnterLabel.text = @"Word will not contain special characters";
        self.wordEnterLabel.textColor = [UIColor redColor];
        return;
    }
    
    //If the input is one letter:
    if ([guessLetter length] == 1)
    {
        //Check if the player has guessed this letter previously
        if ([self.guessedLetters containsObject:guessLetter])
        {
            self.wordEnterLabel.text = @"You already guessed that letter";
            self.wordEnterLabel.textColor = [UIColor redColor];
            return;
        }
        else
        {
            [self.guessedLetters addObject:guessLetter];
        }
        //Catch if they player has tried to guess a space
        if ([guessLetter isEqualToString:@" "])
        {
            self.wordEnterLabel.text = @"A space is not a valid guess";
            self.wordEnterLabel.textColor = [UIColor redColor];
            return;
        }
        //If the guess was correct:
        if ([self.chosenWordLetters containsObject:guessLetter])
        {
            self.wordEnterLabel.text = @"Good guess!";
            self.wordEnterLabel.textColor = [UIColor blueColor];
            
            //Change the labels to reflect the correctly guessed letter
            for (NSUInteger i = 0; i < [self.chosenWordLetters count]; i++)
            {
                if (self.chosenWordLetters[i] == guessLetter)
                {
                    self.correctGuesses++;
                    NSArray *labels = self.chosenWordLettersLabels;
                    UILabel *thisLabel = labels[i];
                    thisLabel.text = [guessLetter uppercaseString];
                    thisLabel.backgroundColor = [UIColor clearColor];
                }
                else
                {
                    continue;
                }
            }
            //If the player has completed the chosed word:
            if (self.correctGuesses >= [self.chosenWordLetters count])
            {
                self.wordEnterLabel.text = @"YOU WIN! - Press button to restart";
                self.gameOver = YES;
                self.wordEnterTextField.userInteractionEnabled = NO;
            }
        }
        //If the guess was incorrect:
        else
        {
            self.wordEnterLabel.text = @"Ooh, bad guess...";
            self.wordEnterLabel.textColor = [UIColor redColor];
            //Add a body part
            UIImageView *currentBodyPart = self.bodyParts[self.guesses];
            currentBodyPart.hidden = NO;
            self.guesses++;
            
            //If the body is finished, end the game
            if (self.guesses == 5)
            {
                self.wordEnterLabel.text = @"GAME OVER - Press button to restart";
                self.gameOver = YES;
                self.wordEnterTextField.userInteractionEnabled = NO;
                for (NSUInteger i = 0; i < [self.chosenWordLetters count]; i++)
                {
                    NSArray *labels = self.chosenWordLettersLabels;
                    UILabel *thisLabel = labels[i];
                    thisLabel.text = [self.chosenWordLetters[i] uppercaseString];
                    thisLabel.backgroundColor = [UIColor clearColor];
                    thisLabel.textColor = [UIColor redColor];
                }
            }
        }
        
        self.guessedLettersLabel.text = [[self.guessedLettersLabel.text stringByAppendingFormat:@" %@", guessLetter] uppercaseString];
    }
    //If the user puts in something other than a single character:
    else
    {
        self.wordEnterLabel.text = @"Enter a single character as your guess please";
        self.wordEnterLabel.textColor = [UIColor redColor];
    }
}

//Resets the parameters of the game to allow a new play session
- (void)reset
{
    for (UIImageView *bodyPart in self.bodyParts)
    {
        bodyPart.hidden = YES;
    }
    
    for (UILabel *letterLabel in self.chosenWordLettersLabels)
    {
        [letterLabel removeFromSuperview];
    }
    
    self.wordEnterLabel.text = @"Enter a word and press the button";
    self.wordEnterLabel.textColor = [UIColor blackColor];
    
    self.eightOrLessLabel.textColor = [UIColor blackColor];
    
    self.guessedLettersLabel.text = @"GUESSED LETTERS:";
    
    [self.chosenWordLettersLabels removeAllObjects];
    [self.guessedLetters          removeAllObjects];
    [self.chosenWordLetters       removeAllObjects];
    
    [self viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
