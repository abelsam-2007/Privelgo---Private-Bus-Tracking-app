const express = require('express');
const cors = require('cors');
const http = require('http');

const path = require('path');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../dashboard')));


// ==========================================
// SEED DATA (In-Memory Database Simulation)
// ==========================================

const STOPS = [
    { id: 1, name: "Colombo Central", lat: 6.9322, lon: 79.8450, shelter: true, facilities: ["Seats", "LED Display", "USB Charging"] },
    { id: 2, name: "Liberty Junction", lat: 6.9180, lon: 79.8510, shelter: true, facilities: ["Seats", "LED Display"] },
    { id: 3, name: "Town Hall", lat: 6.9125, lon: 79.8640, shelter: true, facilities: ["Seats", "WiFi"] },
    { id: 4, name: "Borella", lat: 6.9140, lon: 79.8800, shelter: false, facilities: ["Lighting"] },
    { id: 5, name: "Narahenpita", lat: 6.8970, lon: 79.8810, shelter: true, facilities: ["Seats"] },
    { id: 6, name: "Havelock Town", lat: 6.8880, lon: 79.8610, shelter: true, facilities: ["Seats", "LED Display"] },
    { id: 7, name: "Wellawatte", lat: 6.8720, lon: 79.8600, shelter: true, facilities: ["Seats", "LED Display", "Wheelchair Ramp"] },
    { id: 8, name: "Dehiwala", lat: 6.8510, lon: 79.8630, shelter: true, facilities: ["Seats"] },
    { id: 9, name: "Mount Lavinia", lat: 6.8340, lon: 79.8660, shelter: true, facilities: ["Seats", "LED Display"] },
    { id: 10, name: "Nugegoda", lat: 6.8760, lon: 79.8880, shelter: true, facilities: ["Seats"] }
];

const ROUTES = [
    {
        id: 1,
        routeNumber: "138",
        name: "Kottawa - Pettah",
        stops: [1, 2, 3, 4, 10],
        distanceKm: 18.5,
        durationMins: 45,
        operatingHours: "05:00 - 22:30",
        frequencyMins: 8,
        baseFare: 40.00
    },
    {
        id: 2,
        routeNumber: "100",
        name: "Panadura - Pettah",
        stops: [1, 2, 6, 7, 8, 9],
        distanceKm: 28.0,
        durationMins: 60,
        operatingHours: "04:30 - 23:00",
        frequencyMins: 6,
        baseFare: 50.00
    },
    {
        id: 3,
        routeNumber: "176",
        name: "Karagampitiya - Hettiyawatta",
        stops: [8, 7, 6, 5, 4],
        distanceKm: 22.0,
        durationMins: 55,
        operatingHours: "05:30 - 21:30",
        frequencyMins: 12,
        baseFare: 45.00
    }
];

let BUSES = [
    {
        id: 101,
        busNumber: "WP-ND-8432",
        busName: "Privelgo Express Blue",
        operatorId: 1,
        operatorName: "Express Transit Co.",
        driverId: 2,
        driverName: "Sunil Perera",
        routeId: 1,
        routeNumber: "138",
        capacity: 42,
        currentPassengers: 14,
        crowdednessLevel: "seats_available", // seats_available, moderately_crowded, full
        isAC: true,
        isWifi: true,
        isAccessible: true,
        currentStatus: "active", // active, inactive, break, delayed
        lat: 6.925,
        lon: 79.848,
        speed: 35.5,
        direction: 180,
        delayMinutes: 0,
        lastUpdated: new Date().toISOString()
    },
    {
        id: 102,
        busNumber: "WP-NB-5544",
        busName: "Lanka Luxury Star",
        operatorId: 1,
        operatorName: "Express Transit Co.",
        driverId: 3,
        driverName: "Amara Silva",
        routeId: 2,
        routeNumber: "100",
        capacity: 40,
        currentPassengers: 35,
        crowdednessLevel: "moderately_crowded",
        isAC: true,
        isWifi: false,
        isAccessible: false,
        currentStatus: "active",
        lat: 6.882,
        lon: 79.860,
        speed: 28.0,
        direction: 355,
        delayMinutes: 3,
        lastUpdated: new Date().toISOString()
    },
    {
        id: 103,
        busNumber: "WP-NC-9912",
        busName: "City Commuter Lite",
        operatorId: 2,
        operatorName: "Southern Metro Buses",
        driverId: 4,
        driverName: "K. Alwis",
        routeId: 3,
        routeNumber: "176",
        capacity: 35,
        currentPassengers: 35,
        crowdednessLevel: "full",
        isAC: false,
        isWifi: false,
        isAccessible: true,
        currentStatus: "delayed",
        lat: 6.902,
        lon: 79.875,
        speed: 12.0,
        direction: 90,
        delayMinutes: 8,
        lastUpdated: new Date().toISOString()
    }
];

let REVIEWS = [
    {
        id: 1,
        busId: 101,
        userName: "Sanduni Fernando",
        rating: 5,
        comment: "Extremely clean bus with very fast WiFi. The AC is perfect for Colombo heat!",
        cleanlinessScore: 5,
        comfortScore: 5,
        driverBehaviorScore: 5,
        punctualityScore: 5,
        likes: 12,
        createdAt: "2026-07-07T12:00:00Z"
    },
    {
        id: 2,
        busId: 102,
        userName: "M. R. Mohamed",
        rating: 4,
        comment: "Punctual bus, but it got quite crowded during office closing hours. Clean and safe driving.",
        cleanlinessScore: 4,
        comfortScore: 3,
        driverBehaviorScore: 4,
        punctualityScore: 5,
        likes: 5,
        createdAt: "2026-07-08T08:30:00Z"
    }
];

let COMPLAINTS = [];
let TICKETS = [];
let USER_PROFILE = {
    name: "Alex Dev",
    email: "alex@privelgo.com",
    role: "passenger",
    rewardPoints: 240,
    savedPlaces: [
        { id: 1, name: "Home", address: "Dehiwala Road, Mount Lavinia", lat: 6.8340, lon: 79.8660 },
        { id: 2, name: "Work / Office", address: "World Trade Center, Colombo Central", lat: 6.9322, lon: 79.8450 }
    ],
    travelHistory: [
        { id: 1, date: "2026-07-08", busNumber: "WP-ND-8432", route: "138 Pettah", fare: 40.00, distance: 8.5, duration: 25 },
        { id: 2, date: "2026-07-07", busNumber: "WP-NB-5544", route: "100 Panadura", fare: 50.00, distance: 12.0, duration: 32 }
    ]
};

// Helper: Calculate distance using Haversine formula (in km)
function calculateHaversineDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

// ==========================================
// API REST ENDPOINTS
// ==========================================

// --- Home & Status ---
app.get('/api', (req, res) => {
    res.json({ message: "Privelgo API Gateway - Online", version: "1.0.0" });
});

// --- Authentication Simulator ---
app.post('/api/auth/login', (req, res) => {
    const { email, password } = req.body;
    if (email === "driver@privelgo.com") {
        return res.json({ token: "mock_jwt_driver_token", role: "driver", user: { id: 2, name: "Sunil Perera", email } });
    }
    if (email === "admin@privelgo.com") {
        return res.json({ token: "mock_jwt_admin_token", role: "admin", user: { id: 99, name: "System Admin", email } });
    }
    // Default passenger login
    res.json({
        token: "mock_jwt_passenger_token",
        role: "passenger",
        user: { id: 1, name: USER_PROFILE.name, email: USER_PROFILE.email, rewardPoints: USER_PROFILE.rewardPoints }
    });
});

// --- User Profile & Favorites ---
app.get('/api/user/profile', (req, res) => {
    res.json(USER_PROFILE);
});

app.post('/api/user/saved-places', (req, res) => {
    const { name, address, lat, lon } = req.body;
    const newPlace = { id: Date.now(), name, address, lat, lon };
    USER_PROFILE.savedPlaces.push(newPlace);
    res.status(201).json(newPlace);
});

// --- Live Bus List & Detail ---
app.get('/api/buses', (req, res) => {
    res.json(BUSES);
});

app.get('/api/buses/:id', (req, res) => {
    const bus = BUSES.find(b => b.id === parseInt(req.params.id));
    if (!bus) return res.status(404).json({ error: "Bus not found" });
    
    // Add nearby upcoming stops and reviews
    const route = ROUTES.find(r => r.id === bus.routeId);
    const busReviews = REVIEWS.filter(rev => rev.busId === bus.id);
    
    res.json({
        ...bus,
        routeDetails: route,
        reviews: busReviews,
        upcomingStops: route ? route.stops.map(sid => STOPS.find(s => s.id === sid)) : []
    });
});

// Update Bus GPS (Driver Simulator trigger)
app.post('/api/buses/:id/location', (req, res) => {
    const busId = parseInt(req.params.id);
    const { lat, lon, speed, direction, delayMinutes, currentPassengers, crowdednessLevel } = req.body;
    
    const busIdx = BUSES.findIndex(b => b.id === busId);
    if (busIdx === -1) return res.status(404).json({ error: "Bus not found" });
    
    if (lat !== undefined) BUSES[busIdx].lat = parseFloat(lat);
    if (lon !== undefined) BUSES[busIdx].lon = parseFloat(lon);
    if (speed !== undefined) BUSES[busIdx].speed = parseFloat(speed);
    if (direction !== undefined) BUSES[busIdx].direction = parseFloat(direction);
    if (delayMinutes !== undefined) BUSES[busIdx].delayMinutes = parseInt(delayMinutes);
    if (currentPassengers !== undefined) BUSES[busIdx].currentPassengers = parseInt(currentPassengers);
    if (crowdednessLevel !== undefined) BUSES[busIdx].crowdednessLevel = crowdednessLevel;
    
    BUSES[busIdx].lastUpdated = new Date().toISOString();
    
    // Log Socket broadcast simulation
    console.log(`[Socket.IO Broadcast] Bus ${busId} location updated: (${lat}, ${lon})`);
    
    res.json({ success: true, bus: BUSES[busIdx] });
});

// --- Bus Stops ---
app.get('/api/stops', (req, res) => {
    res.json(STOPS);
});

app.get('/api/stops/:id', (req, res) => {
    const stop = STOPS.find(s => s.id === parseInt(req.params.id));
    if (!stop) return res.status(404).json({ error: "Stop not found" });
    
    // Find buses approaching this stop
    const approachingBuses = BUSES.filter(b => {
        const route = ROUTES.find(r => r.id === b.routeId);
        return route && route.stops.includes(stop.id);
    }).map(b => {
        // Calculate dynamic ETA based on mock speed & distance
        const distance = calculateHaversineDistance(b.lat, b.lon, stop.lat, stop.lon);
        const etaMins = Math.max(1, Math.round((distance / (b.speed || 30)) * 60) + b.delayMinutes);
        return {
            busId: b.id,
            busNumber: b.busNumber,
            busName: b.busName,
            routeNumber: b.routeNumber,
            etaMinutes: etaMins,
            distanceKm: parseFloat(distance.toFixed(2)),
            crowdednessLevel: b.crowdednessLevel,
            status: b.currentStatus
        };
    });
    
    res.json({
        ...stop,
        upcomingBuses: approachingBuses.sort((a, b) => a.etaMinutes - b.etaMinutes)
    });
});

// --- Route Details & Map Lines ---
app.get('/api/routes', (req, res) => {
    res.json(ROUTES);
});

app.get('/api/routes/:id', (req, res) => {
    const route = ROUTES.find(r => r.id === parseInt(req.params.id));
    if (!route) return res.status(404).json({ error: "Route not found" });
    
    const routeStops = route.stops.map((sid, idx) => {
        const s = STOPS.find(stop => stop.id === sid);
        return {
            ...s,
            sequenceOrder: idx + 1,
            distanceFromStartKm: (idx * 3.5).toFixed(1), // Mock distance accumulation
            fareStage: idx + 1
        };
    });
    
    res.json({
        ...route,
        stopsList: routeStops
    });
});

// --- Smart Route Recommendation & Fare Calculator ---
app.post('/api/route-search', (req, res) => {
    const { startLat, startLon, destLat, destLon, userType } = req.body;
    
    if (!startLat || !startLon || !destLat || !destLon) {
        return res.status(400).json({ error: "Start and destination coordinates are required." });
    }
    
    // Find nearest stops to starting location and destination
    let nearestStartStop = null;
    let minStartDist = Infinity;
    let nearestDestStop = null;
    let minDestDist = Infinity;
    
    STOPS.forEach(stop => {
        const startDist = calculateHaversineDistance(startLat, startLon, stop.lat, stop.lon);
        if (startDist < minStartDist) {
            minStartDist = startDist;
            nearestStartStop = stop;
        }
        
        const destDist = calculateHaversineDistance(destLat, destLon, stop.lat, stop.lon);
        if (destDist < minDestDist) {
            minDestDist = destDist;
            nearestDestStop = stop;
        }
    });
    
    // Find routes containing both stops in sequence
    const directRoutes = [];
    ROUTES.forEach(route => {
        const startIdx = route.stops.indexOf(nearestStartStop.id);
        const destIdx = route.stops.indexOf(nearestDestStop.id);
        
        if (startIdx !== -1 && destIdx !== -1 && startIdx < destIdx) {
            const stopsCount = destIdx - startIdx;
            const distance = stopsCount * 3.5; // Mock km between stops
            const travelDuration = stopsCount * 8; // Mock 8 mins per stop
            
            // Calculate base fare
            let fare = route.baseFare + (stopsCount * 5.0);
            
            // Apply Fare Discounts
            let discountText = "Standard Fare";
            if (userType === 'student') {
                fare = fare * 0.5; // 50% Student Discount
                discountText = "Student Discount (50% Off)";
            } else if (userType === 'senior') {
                fare = fare * 0.7; // 30% Senior Discount
                discountText = "Senior Citizen Discount (30% Off)";
            }
            
            // Check active bus operating on this route
            const activeBus = BUSES.find(b => b.routeId === route.id && b.currentStatus === 'active') || BUSES.find(b => b.routeId === route.id);
            
            directRoutes.push({
                routeId: route.id,
                routeNumber: route.routeNumber,
                name: route.name,
                recommendedBus: activeBus ? {
                    id: activeBus.id,
                    busNumber: activeBus.busNumber,
                    busName: activeBus.busName,
                    crowdedness: activeBus.crowdednessLevel,
                    delayMinutes: activeBus.delayMinutes
                } : null,
                metrics: {
                    distanceKm: parseFloat(distance.toFixed(1)),
                    durationMins: travelDuration + (activeBus ? activeBus.delayMinutes : 0),
                    stopsCount: stopsCount,
                    walkingDistanceStartM: Math.round(minStartDist * 1000),
                    walkingDistanceDestM: Math.round(minDestDist * 1000),
                    totalWalkingDistanceM: Math.round((minStartDist + minDestDist) * 1000),
                    fare: parseFloat(fare.toFixed(2)),
                    fareType: discountText
                },
                directions: [
                    `Walk ${Math.round(minStartDist * 1000)}m to stop "${nearestStartStop.name}".`,
                    `Board Bus ${route.routeNumber} (${route.name}) at "${nearestStartStop.name}".`,
                    `Ride for ${stopsCount} stops (approx. ${travelDuration} mins).`,
                    `Get off at stop "${nearestDestStop.name}".`,
                    `Walk ${Math.round(minDestDist * 1000)}m to your destination.`
                ]
            });
        }
    });
    
    // Sort and formulate recommendations
    // 1. Fastest: minimize duration
    // 2. Cheapest: minimize fare
    // 3. Comfort: select least crowded
    
    const recommendations = [];
    if (directRoutes.length > 0) {
        // Recommendations
        const sortedByTime = [...directRoutes].sort((a, b) => a.metrics.durationMins - b.metrics.durationMins);
        const sortedByPrice = [...directRoutes].sort((a, b) => a.metrics.fare - b.metrics.fare);
        const sortedByComfort = [...directRoutes].sort((a, b) => {
            const getCrowdScore = (bObj) => {
                if (!bObj.recommendedBus) return 0;
                if (bObj.recommendedBus.crowdedness === 'seats_available') return 1;
                if (bObj.recommendedBus.crowdedness === 'moderately_crowded') return 2;
                return 3;
            };
            return getCrowdScore(a) - getCrowdScore(b);
        });
        
        recommendations.push({
            type: "Fastest / Best Route ⚡",
            ...sortedByTime[0]
        });
        
        if (sortedByPrice[0].routeId !== sortedByTime[0].routeId) {
            recommendations.push({
                type: "Cheapest Option 💰",
                ...sortedByPrice[0]
            });
        }
        
        if (sortedByComfort[0].routeId !== sortedByTime[0].routeId && sortedByComfort[0].routeId !== sortedByPrice[0].routeId) {
            recommendations.push({
                type: "Least Crowded Option 🛋️",
                ...sortedByComfort[0]
            });
        }
    } else {
        // Mock fallback transitting route if no direct path exists
        recommendations.push({
            type: "Multi-Transfer Route 🔄 (Colombo Outer Circle)",
            routeNumber: "138 ➔ 176",
            metrics: {
                distanceKm: 25.4,
                durationMins: 75,
                stopsCount: 12,
                walkingDistanceStartM: 350,
                walkingDistanceDestM: 150,
                totalWalkingDistanceM: 500,
                fare: 85.00,
                fareType: "Standard Fare"
            },
            directions: [
                "Walk 350m to Colombo Central stop.",
                "Board Bus 138 (Kottawa - Pettah) Colombo Central.",
                "Ride for 4 stops and get down at Borella Junction.",
                "Transfer at Borella Junction to Bus 176.",
                "Ride 8 stops and get down at Dehiwala.",
                "Walk 150m to your final destination."
            ]
        });
    }
    
    res.json({
        searchedPoints: { startStop: nearestStartStop.name, destStop: nearestDestStop.name },
        recommendations
    });
});

// --- Passenger Review System ---
app.get('/api/reviews', (req, res) => {
    res.json(REVIEWS);
});

app.post('/api/reviews', (req, res) => {
    const { busId, rating, comment, cleanlinessScore, comfortScore, driverBehaviorScore, punctualityScore } = req.body;
    
    if (!busId || !rating) {
        return res.status(400).json({ error: "busId and rating are required." });
    }
    
    const newReview = {
        id: REVIEWS.length + 1,
        busId: parseInt(busId),
        userName: "Alex Dev (You)",
        rating: parseInt(rating),
        comment: comment || "",
        cleanlinessScore: parseInt(cleanlinessScore || rating),
        comfortScore: parseInt(comfortScore || rating),
        driverBehaviorScore: parseInt(driverBehaviorScore || rating),
        punctualityScore: parseInt(punctualityScore || rating),
        likes: 0,
        createdAt: new Date().toISOString()
    };
    
    REVIEWS.unshift(newReview); // Add to beginning of reviews feed
    
    // Add gamification rewards
    USER_PROFILE.rewardPoints += 15; // 15 points for posting a review!
    
    res.status(201).json({
        message: "Review submitted successfully! Earned 15 Privelgo points.",
        rewardPoints: USER_PROFILE.rewardPoints,
        review: newReview
    });
});

// --- Complaints & Incident Reports ---
app.post('/api/reports', (req, res) => {
    const { busId, category, description } = req.body;
    if (!busId || !category || !description) {
        return res.status(400).json({ error: "Missing required complaint details" });
    }
    const newComplaint = {
        id: COMPLAINTS.length + 1,
        busId: parseInt(busId),
        busNumber: BUSES.find(b => b.id === parseInt(busId))?.busNumber || "Unknown",
        category,
        description,
        status: "pending",
        createdAt: new Date().toISOString()
    };
    COMPLAINTS.unshift(newComplaint);
    res.status(201).json({ message: "SOS/Complaint filed. Authorities and operators notified.", complaint: newComplaint });
});

app.get('/api/admin/complaints', (req, res) => {
    res.json(COMPLAINTS);
});

// --- Future Ready Digital Tickets ---
app.post('/api/tickets/purchase', (req, res) => {
    const { routeId, fare, ticketType } = req.body;
    const newTicket = {
        id: TICKETS.length + 1,
        userId: 1,
        routeId: parseInt(routeId),
        fare: parseFloat(fare),
        ticketType: ticketType || "single",
        qrCode: `PRIVELGO-TKT-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
        status: "active",
        purchaseTime: new Date().toISOString()
    };
    TICKETS.push(newTicket);
    res.status(201).json({ message: "Ticket purchased successfully!", ticket: newTicket });
});

app.get('/api/tickets', (req, res) => {
    res.json(TICKETS);
});

// --- AI Travel Assistant ---
app.post('/api/assistant/ask', (req, res) => {
    const { question } = req.body;
    
    if (!question) {
        return res.status(400).json({ error: "Please ask a question." });
    }
    
    const query = question.toLowerCase();
    let reply = "I'm sorry, I couldn't understand that request. Try asking about which bus to take, fares, delays, or crowdedness levels!";
    
    if (query.includes("which bus") || query.includes("how to go") || query.includes("route")) {
        reply = "To go from Colombo Central to Mount Lavinia, board Bus 100 at Colombo Central. It travels along Galle Road, stopping at Wellawatte and Dehiwala, taking approximately 40 minutes.";
    } else if (query.includes("cheapest")) {
        reply = "The cheapest option is taking standard non-AC buses. Taking Bus 138 costs a base of 40 LKR. Also, student IDs entitle you to a 50% discount on fare stages.";
    } else if (query.includes("how long") || query.includes("duration") || query.includes("time")) {
        reply = "Currently, Bus 138 takes 45 minutes to cover the route. Traffic in Borella is moderate, resulting in minor delays of up to 3 minutes for Bus 102.";
    } else if (query.includes("crowd") || query.includes("seat") || query.includes("occupancy")) {
        const fullBuses = BUSES.filter(b => b.crowdednessLevel === 'full').map(b => b.busNumber).join(", ");
        const seatsBuses = BUSES.filter(b => b.crowdednessLevel === 'seats_available').map(b => b.busNumber).join(", ");
        reply = `Bus occupancy update: Bus ${seatsBuses || "WP-ND-8432"} has seats available 🟢. However, Bus ${fullBuses || "WP-NC-9912"} is currently full 🔴.`;
    } else if (query.includes("late") || query.includes("delay") || query.includes("on time")) {
        const delayed = BUSES.filter(b => b.delayMinutes > 0);
        if (delayed.length > 0) {
            reply = "Currently: " + delayed.map(b => `Bus ${b.busNumber} is delayed by ${b.delayMinutes} mins due to heavy traffic.`).join(" | ");
        } else {
            reply = "All active Privelgo fleet buses are running on schedule right now! 🟢";
        }
    }
    
    res.json({ answer: reply });
});

// ==========================================
// START SERVER
// ==========================================
app.listen(PORT, () => {
    console.log(`====================================================`);
    console.log(`  Privelgo REST API Server is running on port ${PORT}`);
    console.log(`  End points: http://localhost:${PORT}/api`);
    console.log(`====================================================`);
});
