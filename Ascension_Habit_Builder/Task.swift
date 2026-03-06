//
//  Task.swift
//  Ascension_Habit_Builder
//
//  Created by Luke Downie on 3/5/26.
//

import Foundation
import SwiftData

@Model
final class Task {
    var prompt: String
    var sortOrder: Int
    
    init(prompt: String, sortOrder: Int = 0) {
        self.prompt = prompt
        self.sortOrder = sortOrder
    }
}

// MARK: - Default Task Library Prompts
extension Task {
    static let defaultPrompts: [String] = [
        "Drink a full glass of water",
        "Do 10 pushups (or wall pushups)",
        "Do 15 squats",
        "Do a 30-second plank",
        "Walk for 3 minutes",
        "Stretch your hamstrings for 45 seconds",
        "Stretch your hips for 45 seconds",
        "Stretch your chest for 45 seconds",
        "Do 20 jumping jacks",
        "Do 10 lunges (each leg)",
        "Do 20 calf raises",
        "Do 30 seconds of high knees",
        "Do 30 seconds of jogging in place",
        "Take 12 slow deep breaths",
        "Do 60 seconds of box breathing (4-4-4-4)",
        "Do 1 minute of quiet breathing (no phone)",
        "Stand up and fix your posture for 60 seconds",
        "Do 10 shoulder rolls each direction",
        "Do 10 neck stretches (slow, gentle)",
        "Do 30 seconds of side-to-side torso twists",
        "Touch your toes 10 times (slow)",
        "Do 15 glute bridges",
        "Do 10 chair dips",
        "Do a 30-second wall sit",
        "Do 30 seconds of balance (one foot, then the other)",
        "Drink water and walk around for 2 minutes",
        "Do 20 arm circles (10 forward, 10 back)",
        "Do 10 slow air squats (very controlled)",
        "Do 15 mountain climbers",
        "Do 10 \"superman\" back extensions",
        "Stretch your calves for 45 seconds",
        "Stretch your wrists for 45 seconds",
        "Do 5 deep belly breaths (hand on stomach)",
        "Do 2 minutes of light cleaning as movement",
        "Step outside for 2 minutes of fresh air",
        "Look far away for 30 seconds (eye break)",
        "Do 10 standing knee-to-elbow crunches (each side)",
        "Do 15 seconds of fast jumping jacks + 45 seconds rest",
        "Drink water slowly (no chugging)",
        "Do 1 minute of slow walking and breathing",
        "Do 10 pushups on knees (or wall)",
        "Do 15 squats and hold the last one for 10 seconds",
        "Do 30 seconds of plank + 30 seconds rest",
        "Do 10 reverse lunges each leg",
        "Do 20-second cold water splash on face (if possible)",
        "Do 1 minute of stretching your full body",
        "Do 10 deep breaths with shoulders relaxed",
        "Walk up and down stairs for 2 minutes (if available)",
        "Do 30 seconds of jumping in place",
        "Drink water, then write 1 sentence: \"I did my health task.\""
    ]
}
