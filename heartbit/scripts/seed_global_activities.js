// Firestore Seed Script for Global Activities
// Run this in Firebase Console -> Firestore -> Shell or use Firebase Admin SDK

// Collection: global_activities

const globalActivities = [
    // 🏠 Chill @ Home
    {
        id: "ga_chill_001",
        title: "Movie Marathon Night",
        description: "Pick a trilogy or series and binge watch together with popcorn",
        imageUrl: "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800",
        category: "chill_home",
        intensityLevel: 1,
        estimatedTime: "3-4 hours",
        budgetLevel: 1,
        tags: ["movies", "cozy", "low-key"],
        isActive: true
    },
    {
        id: "ga_chill_002",
        title: "Cook a New Recipe Together",
        description: "Find a recipe you've never tried and make it together",
        imageUrl: "https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=800",
        category: "chill_home",
        intensityLevel: 2,
        estimatedTime: "1-2 hours",
        budgetLevel: 2,
        tags: ["cooking", "creative", "teamwork"],
        isActive: true
    },
    {
        id: "ga_chill_003",
        title: "Board Game Battle",
        description: "Break out the board games and have a friendly competition",
        imageUrl: "https://images.unsplash.com/photo-1606503153255-59d8b2e4b0b0?w=800",
        category: "chill_home",
        intensityLevel: 1,
        estimatedTime: "1-2 hours",
        budgetLevel: 1,
        tags: ["games", "fun", "competitive"],
        isActive: true
    },
    {
        id: "ga_chill_004",
        title: "Spa Night at Home",
        description: "Face masks, candles, and relaxation - create your own spa",
        imageUrl: "https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=800",
        category: "chill_home",
        intensityLevel: 1,
        estimatedTime: "1-2 hours",
        budgetLevel: 2,
        tags: ["relaxation", "self-care", "romantic"],
        isActive: true
    },
    {
        id: "ga_chill_005",
        title: "Build a Pillow Fort",
        description: "Channel your inner child and build the ultimate pillow fort",
        imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800",
        category: "chill_home",
        intensityLevel: 1,
        estimatedTime: "30 min - 1 hour",
        budgetLevel: 1,
        tags: ["playful", "creative", "cozy"],
        isActive: true
    },

    // 🌙 Night Out
    {
        id: "ga_night_001",
        title: "Candlelit Dinner",
        description: "Dress up and enjoy a romantic dinner at a nice restaurant",
        imageUrl: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800",
        category: "night_out",
        intensityLevel: 2,
        estimatedTime: "2-3 hours",
        budgetLevel: 3,
        tags: ["romantic", "food", "classy"],
        isActive: true
    },
    {
        id: "ga_night_002",
        title: "Late Night Cafe Hopping",
        description: "Explore different cafes and find your new favorite spot",
        imageUrl: "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800",
        category: "night_out",
        intensityLevel: 1,
        estimatedTime: "2-3 hours",
        budgetLevel: 2,
        tags: ["coffee", "exploration", "cozy"],
        isActive: true
    },
    {
        id: "ga_night_003",
        title: "Rooftop Bar Experience",
        description: "Find a rooftop bar with a view and enjoy cocktails together",
        imageUrl: "https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=800",
        category: "night_out",
        intensityLevel: 2,
        estimatedTime: "2-3 hours",
        budgetLevel: 3,
        tags: ["drinks", "views", "sophisticated"],
        isActive: true
    },
    {
        id: "ga_night_004",
        title: "Live Music Night",
        description: "Find a local venue with live music and enjoy the performance",
        imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800",
        category: "night_out",
        intensityLevel: 2,
        estimatedTime: "2-4 hours",
        budgetLevel: 2,
        tags: ["music", "entertainment", "energetic"],
        isActive: true
    },
    {
        id: "ga_night_005",
        title: "Late Night Bowling",
        description: "Hit the bowling alley for some friendly competition",
        imageUrl: "https://images.unsplash.com/photo-1545127398-14699f92334b?w=800",
        category: "night_out",
        intensityLevel: 2,
        estimatedTime: "1-2 hours",
        budgetLevel: 2,
        tags: ["active", "fun", "competitive"],
        isActive: true
    },

    // 🏔️ Adventure
    {
        id: "ga_adventure_001",
        title: "Sunrise Hike",
        description: "Wake up early and catch the sunrise from a scenic viewpoint",
        imageUrl: "https://images.unsplash.com/photo-1551632811-561732d1e306?w=800",
        category: "adventure",
        intensityLevel: 3,
        estimatedTime: "3-5 hours",
        budgetLevel: 1,
        tags: ["nature", "active", "memorable"],
        isActive: true
    },
    {
        id: "ga_adventure_002",
        title: "Beach Day Trip",
        description: "Pack a picnic and spend the day at the beach",
        imageUrl: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
        category: "adventure",
        intensityLevel: 2,
        estimatedTime: "Full day",
        budgetLevel: 2,
        tags: ["beach", "relaxing", "outdoors"],
        isActive: true
    },
    {
        id: "ga_adventure_003",
        title: "Bike Ride Through the City",
        description: "Rent bikes and explore your city from a new perspective",
        imageUrl: "https://images.unsplash.com/photo-1541625602330-2277a4c46182?w=800",
        category: "adventure",
        intensityLevel: 2,
        estimatedTime: "2-3 hours",
        budgetLevel: 2,
        tags: ["active", "exploration", "outdoors"],
        isActive: true
    },
    {
        id: "ga_adventure_004",
        title: "Road Trip to Nowhere",
        description: "Pick a direction and just drive - see where you end up",
        imageUrl: "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800",
        category: "adventure",
        intensityLevel: 2,
        estimatedTime: "Half day",
        budgetLevel: 2,
        tags: ["spontaneous", "exploration", "freedom"],
        isActive: true
    },
    {
        id: "ga_adventure_005",
        title: "Kayaking Together",
        description: "Rent kayaks and paddle along a river or lake",
        imageUrl: "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800",
        category: "adventure",
        intensityLevel: 3,
        estimatedTime: "2-3 hours",
        budgetLevel: 2,
        tags: ["water", "active", "nature"],
        isActive: true
    },

    // 🔥 Spicy
    {
        id: "ga_spicy_001",
        title: "Sunset Picnic",
        description: "Pack wine and cheese, find a romantic spot to watch the sunset",
        imageUrl: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800",
        category: "spicy",
        intensityLevel: 1,
        estimatedTime: "1-2 hours",
        budgetLevel: 2,
        tags: ["romantic", "intimate", "nature"],
        isActive: true
    },
    {
        id: "ga_spicy_002",
        title: "Couples Massage",
        description: "Book a couples massage at a spa for ultimate relaxation",
        imageUrl: "https://images.unsplash.com/photo-1600334129128-685c5582fd35?w=800",
        category: "spicy",
        intensityLevel: 1,
        estimatedTime: "1-2 hours",
        budgetLevel: 4,
        tags: ["relaxation", "intimate", "pampering"],
        isActive: true
    },
    {
        id: "ga_spicy_003",
        title: "Stargazing Night",
        description: "Drive away from city lights and marvel at the stars together",
        imageUrl: "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800",
        category: "spicy",
        intensityLevel: 1,
        estimatedTime: "2-3 hours",
        budgetLevel: 1,
        tags: ["romantic", "peaceful", "memorable"],
        isActive: true
    },
    {
        id: "ga_spicy_004",
        title: "Dance Class Together",
        description: "Sign up for a salsa, tango, or bachata class",
        imageUrl: "https://images.unsplash.com/photo-1504609813442-a8924e83f76e?w=800",
        category: "spicy",
        intensityLevel: 2,
        estimatedTime: "1-2 hours",
        budgetLevel: 2,
        tags: ["dancing", "intimate", "fun"],
        isActive: true
    },
    {
        id: "ga_spicy_005",
        title: "Recreate Your First Date",
        description: "Go back to where it all started and relive the magic",
        imageUrl: "https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?w=800",
        category: "spicy",
        intensityLevel: 2,
        estimatedTime: "Variable",
        budgetLevel: 2,
        tags: ["nostalgic", "romantic", "meaningful"],
        isActive: true
    }
];

// Firebase Console Script (for manual entry)
// Go to Firestore -> Start Collection -> global_activities
// Add documents with the structure above

// Or use the Firebase Admin SDK:
/*
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

globalActivities.forEach(async (activity) => {
  await db.collection('global_activities').doc(activity.id).set(activity);
  console.log(`Added: ${activity.title}`);
});
*/

console.log(`Total activities to seed: ${globalActivities.length}`);
console.log('Categories:', {
    chill_home: globalActivities.filter(a => a.category === 'chill_home').length,
    night_out: globalActivities.filter(a => a.category === 'night_out').length,
    adventure: globalActivities.filter(a => a.category === 'adventure').length,
    spicy: globalActivities.filter(a => a.category === 'spicy').length,
});
