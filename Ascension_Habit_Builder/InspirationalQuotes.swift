//
//  InspirationalQuotes.swift
//  Ascension_Habit_Builder
//
//  Add or edit quotes here. Users never see this list—they only see one random quote at a time.
//

import Foundation

struct Quote {
    let text: String
    let author: String
}

enum InspirationalQuotes {
    static let all: [Quote] = [
        Quote(text: "It always seems impossible until it's done.", author: "Nelson Mandela"),
        Quote(text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", author: "Winston Churchill"),
        Quote(text: "The harder the conflict, the greater the triumph.", author: "George Washington"),
        Quote(text: "Dream big and dare to fail.", author: "Norman Vaughan"),
        Quote(text: "Do what you can, with what you have, where you are.", author: "Theodore Roosevelt"),
        Quote(text: "If you're going through hell, keep going.", author: "Winston Churchill"),
        Quote(text: "Act as if what you do makes a difference. It does.", author: "William James"),
        Quote(text: "The secret of getting ahead is getting started.", author: "Mark Twain"),
        Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt"),
        Quote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt"),
        Quote(text: "Success usually comes to those who are too busy to be looking for it.", author: "Henry David Thoreau"),
        Quote(text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson"),
        Quote(text: "You miss 100% of the shots you don't take.", author: "Wayne Gretzky"),
        Quote(text: "Hardships often prepare ordinary people for an extraordinary destiny.", author: "C.S. Lewis"),
        Quote(text: "Keep your eyes on the stars, and your feet on the ground.", author: "Theodore Roosevelt"),
        Quote(text: "The only place where success comes before work is in the dictionary.", author: "Vidal Sassoon"),
        Quote(text: "Great things are done by a series of small things brought together.", author: "Vincent Van Gogh"),
        Quote(text: "Our greatest glory is not in never falling, but in rising every time we fall.", author: "Confucius"),
        Quote(text: "Start where you are. Use what you have. Do what you can.", author: "Arthur Ashe"),
        Quote(text: "Success is walking from failure to failure with no loss of enthusiasm.", author: "Winston Churchill"),
        Quote(text: "Opportunities don't happen. You create them.", author: "Chris Grosser"),
        Quote(text: "Don't limit your challenges. Challenge your limits.", author: "Jerry Dunn"),
        Quote(text: "A goal is a dream with a deadline.", author: "Napoleon Hill"),
        Quote(text: "If you can dream it, you can do it.", author: "Walt Disney"),
        Quote(text: "Perseverance is not a long race; it is many short races one after the other.", author: "Walter Elliot"),
        Quote(text: "Failure will never overtake me if my determination to succeed is strong enough.", author: "Og Mandino"),
        Quote(text: "Quality means doing it right when no one is looking.", author: "Henry Ford"),
        Quote(text: "The best way out is always through.", author: "Robert Frost"),
        Quote(text: "Do not wait to strike till the iron is hot; make it hot by striking.", author: "William Butler Yeats"),
        Quote(text: "You are never too old to set another goal or to dream a new dream.", author: "C.S. Lewis"),
        Quote(text: "Success is getting what you want. Happiness is wanting what you get.", author: "Dale Carnegie"),
        Quote(text: "The only limit to our realization of tomorrow will be our doubts of today.", author: "Franklin D. Roosevelt"),
        Quote(text: "Don't count the days, make the days count.", author: "Muhammad Ali"),
        Quote(text: "Turn your wounds into wisdom.", author: "Oprah Winfrey"),
        Quote(text: "A river cuts through rock not because of its power but because of its persistence.", author: "James Watkins"),
        Quote(text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius"),
        Quote(text: "Success is the sum of small efforts repeated day in and day out.", author: "Robert Collier"),
        Quote(text: "Your big opportunity may be right where you are now.", author: "Napoleon Hill"),
        Quote(text: "The man who moves a mountain begins by carrying away small stones.", author: "Confucius"),
        Quote(text: "Energy and persistence conquer all things.", author: "Benjamin Franklin"),
        Quote(text: "What you get by achieving your goals is not as important as what you become by achieving them.", author: "Zig Ziglar"),
        Quote(text: "Little by little, one travels far.", author: "J.R.R. Tolkien"),
        Quote(text: "Don't be afraid to give up the good to go for the great.", author: "John D. Rockefeller"),
        Quote(text: "If opportunity doesn't knock, build a door.", author: "Milton Berle"),
        Quote(text: "The difference between ordinary and extraordinary is that little extra.", author: "Jimmy Johnson"),
        Quote(text: "Go as far as you can see; when you get there, you'll be able to see further.", author: "Thomas Carlyle"),
        Quote(text: "Push yourself, because no one else is going to do it for you.", author: "Unknown"),
        Quote(text: "Discipline is the bridge between goals and accomplishment.", author: "Jim Rohn"),
        Quote(text: "A winner is a dreamer who never gives up.", author: "Nelson Mandela"),
        Quote(text: "Stay hungry, stay foolish.", author: "Steve Jobs")
    ]
    
    static var random: Quote {
        all.randomElement() ?? all[0]
    }
}
