// Firestore Activity Seed Script
// Run this in Firebase Console -> Firestore -> Start Collection "activities"
// Or use Firebase Admin SDK

const activities = [
    {
        id: "activity_001",
        title: "Movie Night",
        description: "Cozy up with blankets and watch a film together",
        imageUrl: "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800",
        category: "entertainment",
        estimatedTime: "2-3 hours",
        budgetLevel: 2,
        moods: ["chill", "romantic"],
        isDefault: true
    },
    {
        id: "activity_002",
        title: "Cooking Together",
        description: "Pick a new recipe and make dinner as a team",
        imageUrl: "https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=800",
        category: "food",
        estimatedTime: "1-2 hours",
        budgetLevel: 2,
        moods: ["fun", "creative"],
        isDefault: true
    },
    {
        id: "activity_003",
        title: "Sunset Walk",
        description: "Take a peaceful stroll and watch the sunset",
        imageUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800",
        category: "outdoors",
        estimatedTime: "1 hour",
        budgetLevel: 1,
        moods: ["romantic", "chill"],
        isDefault: true
    },
    {
        id: "activity_004",
        title: "Game Night",
        description: "Board games, card games, or video games - you choose!",
        imageUrl: "https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?w=800",
        category: "entertainment",
        estimatedTime: "2-4 hours",
        budgetLevel: 1,
        moods: ["fun", "adventure"],
        isDefault: true
    },
    {
        id: "activity_005",
        title: "Cafe Hopping",
        description: "Explore new cafes in your city together",
        imageUrl: "https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800",
        category: "food",
        estimatedTime: "2-3 hours",
        budgetLevel: 2,
        moods: ["adventure", "chill"],
        isDefault: true
    },
    {
        id: "activity_006",
        title: "Stargazing",
        description: "Find a dark spot and gaze at the stars",
        imageUrl: "https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?w=800",
        category: "outdoors",
        estimatedTime: "1-2 hours",
        budgetLevel: 1,
        moods: ["romantic", "chill"],
        isDefault: true
    },
    {
        id: "activity_007",
        title: "Art Class Together",
        description: "Try painting, pottery, or a craft workshop",
        imageUrl: "https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=800",
        category: "creative",
        estimatedTime: "2-3 hours",
        budgetLevel: 3,
        moods: ["creative", "fun"],
        isDefault: true
    },
    {
        id: "activity_008",
        title: "Spa Night at Home",
        description: "Face masks, candles, and relaxation",
        imageUrl: "https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=800",
        category: "relaxation",
        estimatedTime: "1-2 hours",
        budgetLevel: 2,
        moods: ["chill", "romantic"],
        isDefault: true
    },
    {
        id: "activity_009",
        title: "Road Trip",
        description: "Pick a destination and hit the road",
        imageUrl: "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800",
        category: "adventure",
        estimatedTime: "Full day",
        budgetLevel: 3,
        moods: ["adventure", "fun"],
        isDefault: true
    },
    {
        id: "activity_010",
        title: "Photo Walk",
        description: "Explore your city and take photos of each other",
        imageUrl: "https://images.unsplash.com/photo-1452587925148-ce544e77e70d?w=800",
        category: "creative",
        estimatedTime: "2-3 hours",
        budgetLevel: 1,
        moods: ["creative", "adventure"],
        isDefault: true
    }
];

// To add to Firestore using Admin SDK:
// const admin = require('firebase-admin');
// admin.initializeApp();
// const db = admin.firestore();
//
// activities.forEach(async (activity) => {
//   await db.collection('activities').doc(activity.id).set(activity);
// });
