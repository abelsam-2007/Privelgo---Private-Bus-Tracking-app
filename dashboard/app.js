// ==========================================================================
// Privelgo Dashboard Simulation Engine
// ==========================================================================

// Global state variables
let map, passengerMarker, destinationMarker;
let activeBuses = {}; // Bus markers mapped by ID
let routeLine = null;
let currentSelectedBusId = 101;
let rewardPoints = 240;
let reviews = [
    { id: 1, user: "Sanduni Fernando", rating: 5, comment: "Extremely clean bus with very fast WiFi. The AC is perfect for Colombo heat!", status: "approved" },
    { id: 2, user: "M. R. Mohamed", rating: 4, comment: "Punctual bus, but it got quite crowded during office hours. Clean and safe driving.", status: "approved" }
];
let driverTripActive = false;
let driveInterval = null;
let driveStep = 0;

// Colombo coordinates config
const COLOMBO_COORDS = [6.885, 79.865];

// Map stop locations matching REST API data
const STOPS = [
    { id: 1, name: "Colombo Central", lat: 6.9322, lon: 79.8450, shelter: true },
    { id: 2, name: "Liberty Junction", lat: 6.9180, lon: 79.8510, shelter: true },
    { id: 3, name: "Town Hall", lat: 6.9125, lon: 79.8640, shelter: true },
    { id: 4, name: "Borella", lat: 6.9140, lon: 79.8800, shelter: false },
    { id: 5, name: "Narahenpita", lat: 6.8970, lon: 79.8810, shelter: true },
    { id: 6, name: "Havelock Town", lat: 6.8880, lon: 79.8610, shelter: true },
    { id: 7, name: "Wellawatte", lat: 6.8720, lon: 79.8600, shelter: true },
    { id: 8, name: "Dehiwala", lat: 6.8510, lon: 79.8630, shelter: true },
    { id: 9, name: "Mount Lavinia", lat: 6.8340, lon: 79.8660, shelter: true },
    { id: 10, name: "Nugegoda", lat: 6.8760, lon: 79.8880, shelter: true }
];

// Predefined GPS simulation points for Bus 101 (Route 138 path)
const BUS_101_PATH = [
    { lat: 6.9322, lon: 79.8450 }, // Colombo Central
    { lat: 6.9250, lon: 79.8480 },
    { lat: 6.9180, lon: 79.8510 }, // Liberty Junction
    { lat: 6.9145, lon: 79.8580 },
    { lat: 6.9125, lon: 79.8640 }, // Town Hall
    { lat: 6.9130, lon: 79.8720 },
    { lat: 6.9140, lon: 79.8800 }, // Borella
    { lat: 6.8950, lon: 79.8840 },
    { lat: 6.8760, lon: 79.8880 }  // Nugegoda
];

// Predefined GPS points for Bus 102 (Route 100 path)
const BUS_102_PATH = [
    { lat: 6.8340, lon: 79.8660 }, // Mount Lavinia
    { lat: 6.8510, lon: 79.8630 }, // Dehiwala
    { lat: 6.8720, lon: 79.8600 }, // Wellawatte
    { lat: 6.8880, lon: 79.8610 }, // Havelock Town
    { lat: 6.9180, lon: 79.8510 }, // Liberty Junction
    { lat: 6.9322, lon: 79.8450 }  // Colombo Central
];

// ==========================================
// 1. INITIALIZE WEB MAP & CHARTS
// ==========================================
document.addEventListener("DOMContentLoaded", () => {
    initMap();
    initAnalyticsChart();
    renderReviews();
    setupEventListeners();
    updateAdminMetrics();
});

function initMap() {
    // Render Leaflet Map
    map = L.map('passenger-map', {
        zoomControl: false
    }).setView(COLOMBO_COORDS, 12.5);

    // Standard Streets layer
    L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; OpenStreetMap'
    }).addTo(map);

    // Custom Stop Icon (Steel Blue pin)
    const stopIcon = L.divIcon({
        className: 'custom-stop-marker',
        html: '<div style="background-color: #387EA2; width: 10px; height: 10px; border-radius: 50%; border: 2px solid white; box-shadow: 0 1px 4px rgba(0,0,0,0.3)"></div>',
        iconSize: [10, 10]
    });

    // Populate all bus stops on map
    STOPS.forEach(stop => {
        L.marker([stop.lat, stop.lon], { icon: stopIcon })
            .addTo(map)
            .bindPopup(`<strong>${stop.name}</strong><br>Shelter: ${stop.shelter ? "Available 🟢" : "None 🔴"}`);
    });

    // Plot simulated buses
    updateBusMarkerOnMap(101, BUS_101_PATH[0], "138", "#184E6C");
    updateBusMarkerOnMap(102, BUS_102_PATH[0], "100", "#2E7D32");
}

function updateBusMarkerOnMap(id, position, routeNumber, color) {
    if (activeBuses[id]) {
        // Smoothly animate transition
        activeBuses[id].setLatLng([position.lat, position.lon]);
    } else {
        const busIcon = L.divIcon({
            className: 'live-bus-marker',
            html: `<div style="background-color: ${color}; color: white; padding: 4px 8px; border-radius: 8px; font-weight: bold; font-size: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.3); display: flex; align-items: center; gap: 3px;">
                     <i class="fa-solid fa-bus"></i>${routeNumber}
                   </div>`,
            iconSize: [45, 22]
        });

        activeBuses[id] = L.marker([position.lat, position.lon], { icon: busIcon })
            .addTo(map)
            .on('click', () => selectBus(id));
    }
}

// Chart.js implementation for Admin
function initAnalyticsChart() {
    const ctx = document.getElementById('admin-chart').getContext('2d');
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['06:00', '08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00'],
            datasets: [
                {
                    label: 'Bus 138 Occupancy',
                    data: [12, 38, 22, 14, 25, 42, 39, 15],
                    borderColor: '#184E6C',
                    backgroundColor: 'rgba(24, 78, 108, 0.1)',
                    tension: 0.4,
                    fill: true
                },
                {
                    label: 'Bus 100 Occupancy',
                    data: [8, 40, 35, 18, 20, 38, 35, 10],
                    borderColor: '#387EA2',
                    backgroundColor: 'rgba(56, 126, 162, 0.05)',
                    tension: 0.4,
                    fill: true
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false }
            },
            scales: {
                y: { grid: { display: false }, ticks: { font: { size: 9 } } },
                x: { grid: { display: false }, ticks: { font: { size: 9 } } }
            }
        }
    });
}

// ==========================================
// 2. SIMULATOR CONTROLS (DRIVER INTERACTION)
// ==========================================
function setupEventListeners() {
    // --- Driver Controls ---
    const btnToggleGps = document.getElementById("btn-toggle-gps");
    btnToggleGps.addEventListener("click", () => {
        driverTripActive = !driverTripActive;
        if (driverTripActive) {
            btnToggleGps.innerHTML = '<i class="fa-solid fa-pause"></i> Pause Driving Route';
            btnToggleGps.classList.add("active");
            startGpsSimulation();
        } else {
            btnToggleGps.innerHTML = '<i class="fa-solid fa-play"></i> Resume Driving Route';
            btnToggleGps.classList.remove("active");
            clearInterval(driveInterval);
        }
        updateAdminMetrics();
    });

    // Passenger Adjustment
    const btnIncPass = document.getElementById("btn-inc-passengers");
    const btnDecPass = document.getElementById("btn-dec-passengers");
    const driverPassengerCount = document.getElementById("driver-passenger-count");

    btnIncPass.addEventListener("click", () => {
        let count = parseInt(driverPassengerCount.innerText);
        if (count < 42) {
            count++;
            driverPassengerCount.innerText = count;
            syncDriverOccupancy(count);
        }
    });

    btnDecPass.addEventListener("click", () => {
        let count = parseInt(driverPassengerCount.innerText);
        if (count > 0) {
            count--;
            driverPassengerCount.innerText = count;
            syncDriverOccupancy(count);
        }
    });

    // Delay Reporting
    document.getElementById("driver-delay-status").addEventListener("change", (e) => {
        const delayVal = parseInt(e.target.value);
        const delayTag = document.getElementById("sheet-bus-delay");
        
        if (delayVal === 0) {
            delayTag.innerText = "On Time";
            delayTag.className = "delay-tag on-time";
        } else {
            delayTag.innerText = `${delayVal} min late`;
            delayTag.className = "delay-tag late";
        }
        console.log(`[Driver Action] Delay updated: ${delayVal} mins`);
    });

    // Panic SOS Button (Driver)
    document.getElementById("btn-driver-panic").addEventListener("click", () => {
        triggerSosComplaint("Driver Sunil Perera", "WP-ND-8432", "Medical/Security SOS triggered from Driver console!");
        alert("🚨 EMERGENCY SOS BROADCAST SENT TO DISPATCHERS!");
    });

    // --- Passenger Controls ---
    // Passenger types selection chips
    document.querySelectorAll(".p-type-chip").forEach(chip => {
        chip.addEventListener("click", (e) => {
            document.querySelectorAll(".p-type-chip").forEach(c => c.classList.remove("active"));
            chip.classList.add("active");
        });
    });

    // Route Planner button trigger
    document.getElementById("btn-plan-trip").addEventListener("click", performRouteSearch);

    // Map switcher demo
    document.getElementById("map-type-streets").addEventListener("click", () => {
        document.getElementById("map-type-streets").classList.add("active");
        document.getElementById("map-type-satellite").classList.remove("active");
    });
    document.getElementById("map-type-satellite").addEventListener("click", () => {
        document.getElementById("map-type-satellite").classList.add("active");
        document.getElementById("map-type-streets").classList.remove("active");
    });

    // AI assistant
    document.getElementById("btn-ask-ai").addEventListener("click", handleAiAssistantQuery);
    document.getElementById("assistant-query").addEventListener("keypress", (e) => {
        if (e.key === "Enter") handleAiAssistantQuery();
    });

    // Submit review
    document.getElementById("btn-submit-review").addEventListener("click", submitPassengerReview);
    // Rating star handler
    document.querySelectorAll(".star-in").forEach(star => {
        star.addEventListener("click", () => {
            const r = parseInt(star.getAttribute("data-rating"));
            document.querySelectorAll(".star-in").forEach(s => {
                const sR = parseInt(s.getAttribute("data-rating"));
                if (sR <= r) s.classList.add("active");
                else s.classList.remove("active");
            });
            document.querySelector(".rating-stars-input").setAttribute("data-selected-rating", r);
        });
    });
    // Default select 5 stars
    document.querySelector(".rating-stars-input").setAttribute("data-selected-rating", 5);
    document.querySelectorAll(".star-in").forEach(s => s.classList.add("active"));
}

function startGpsSimulation() {
    clearInterval(driveInterval);
    driveInterval = setInterval(() => {
        driveStep = (driveStep + 1) % BUS_101_PATH.length;
        const currentPos = BUS_101_PATH[driveStep];
        
        // Update main bus marker
        updateBusMarkerOnMap(101, currentPos, "138", "#184E6C");
        
        // Update details sheet speed dynamically
        if (currentSelectedBusId === 101) {
            document.getElementById("sheet-bus-speed").innerText = `${Math.floor(Math.random() * 20) + 30} km/h`;
        }

        // Adjust 102 bus slightly for active tracking
        const step102 = Math.min(driveStep, BUS_102_PATH.length - 1);
        updateBusMarkerOnMap(102, BUS_102_PATH[step102], "100", "#2E7D32");

        console.log(`[GPS Sim] Bus 101 coordinates updated: ${currentPos.lat}, ${currentPos.lon}`);
    }, 4000);
}

function syncDriverOccupancy(count) {
    const oText = document.getElementById("sheet-bus-occupancy");
    const oIcon = document.getElementById("sheet-crowd-icon");
    const badgAvail = document.getElementById("badge-seats-avail");
    const badgMod = document.getElementById("badge-mod-crowded");
    const badgFull = document.getElementById("badge-full");

    badgAvail.classList.remove("active");
    badgMod.classList.remove("active");
    badgFull.classList.remove("active");

    if (count < 18) {
        oText.innerText = "🟢 Seats Available";
        oText.className = "seats-available";
        oIcon.className = "fa-solid fa-users text-green";
        badgAvail.classList.add("active");
    } else if (count < 36) {
        oText.innerText = "🟡 Moderately Crowded";
        oText.className = "seats-crowded";
        oIcon.className = "fa-solid fa-users text-orange";
        badgMod.classList.add("active");
    } else {
        oText.innerText = "🔴 Full / Standees Only";
        oText.className = "seats-full";
        oIcon.className = "fa-solid fa-users text-red";
        badgFull.classList.add("active");
    }
    updateAdminMetrics();
}

// ==========================================
// 3. PASSENGER APP PORTAL ROUTING ENGINE
// ==========================================
function performRouteSearch() {
    const startText = document.getElementById("route-start").value.trim();
    const destText = document.getElementById("route-dest").value.trim();
    const activeType = document.querySelector(".p-type-chip.active").getAttribute("data-type");

    if (!startText || !destText) {
        alert("Please enter start location and destination stop.");
        return;
    }

    const recContainer = document.getElementById("recommendations-container");
    const listDiv = document.getElementById("itinerary-list");
    listDiv.innerHTML = "";

    // Euclidean distance simulator proxy
    const stopsCount = 5;
    const duration = 40;
    const walkingDist = 380;
    
    let basePrice = 75.00;
    let typeLabel = "Standard Fare";
    if (activeType === "student") {
        basePrice = basePrice * 0.5;
        typeLabel = "Student Discount (50% Off)";
    } else if (activeType === "senior") {
        basePrice = basePrice * 0.7;
        typeLabel = "Senior Discount (30% Off)";
    }

    // Recommendation 1: Fastest
    const item1 = document.createElement("div");
    item1.className = "itinerary-option-card";
    item1.innerHTML = `
        <div class="itinerary-title-row">
            <h5>⚡ Fastest / Direct Route</h5>
            <span class="itinerary-fare">${basePrice.toFixed(2)} LKR</span>
        </div>
        <div class="itinerary-stats-row">
            <span><i class="fa-solid fa-bus"></i> Bus 100</span>
            <span><i class="fa-solid fa-hourglass-half"></i> ${duration} mins</span>
            <span><i class="fa-solid fa-walking"></i> ${walkingDist}m</span>
            <span><i class="fa-solid fa-arrows-left-right"></i> ${stopsCount} stops</span>
        </div>
        <div class="itinerary-directions">
            <p><strong>Step-by-step Itinerary:</strong></p>
            <ol>
                <li>Walk 130m to stop <strong>Colombo Central</strong>.</li>
                <li>Board Bus 100 heading Panadura at 22:38.</li>
                <li>Ride 5 stops (Wellawatte, Dehiwala, etc).</li>
                <li>Get off at stop <strong>Mount Lavinia</strong>.</li>
                <li>Walk 250m to your final destination.</li>
            </ol>
            <div style="font-size: 8.5px; margin-top:6px; color:#2E7D32; font-weight:700;">Rate Type: ${typeLabel}</div>
        </div>
        <button class="btn-nav-trip" onclick="startMobileNavigation()">Start Navigation</button>
    `;
    listDiv.appendChild(item1);

    // Recommendation 2: Cheapest/Alternative
    const altPrice = basePrice - 15.00;
    const item2 = document.createElement("div");
    item2.className = "itinerary-option-card";
    item2.innerHTML = `
        <div class="itinerary-title-row">
            <h5>🛋️ Least Crowded Alternative</h5>
            <span class="itinerary-fare">${altPrice.toFixed(2)} LKR</span>
        </div>
        <div class="itinerary-stats-row">
            <span><i class="fa-solid fa-bus"></i> Bus 138</span>
            <span><i class="fa-solid fa-hourglass-half"></i> 48 mins</span>
            <span><i class="fa-solid fa-walking"></i> 550m</span>
            <span><i class="fa-solid fa-arrows-left-right"></i> 4 stops</span>
        </div>
        <div class="itinerary-directions">
            <p>Take Bus 138 from Liberty Junction stop. Reports seats available 🟢.</p>
        </div>
    `;
    listDiv.appendChild(item2);

    recContainer.style.display = "block";
    recContainer.scrollIntoView({ behavior: 'smooth' });

    // Show path on map
    plotRoutePath();
}

function plotRoutePath() {
    if (routeLine) {
        map.removeLayer(routeLine);
    }
    // Plot route polyline between Colombo Central and Mount Lavinia stops
    const points = STOPS.map(s => [s.lat, s.lon]);
    routeLine = L.polyline(points, { color: '#387EA2', weight: 4, opacity: 0.8 }).addTo(map);
    map.fitBounds(routeLine.getBounds());
}

function startMobileNavigation() {
    alert("🧭 Passenger navigation started. Real-time GPS guidance active!");
}

// ==========================================
// 4. USER FEEDBACK (REVIEWS & SOS SUBMISSION)
// ==========================================
function selectBus(busId) {
    currentSelectedBusId = busId;
    const sheet = document.getElementById("bus-details-sheet");
    const numText = document.getElementById("sheet-bus-num");
    const nameText = document.getElementById("sheet-bus-name");
    const speedText = document.getElementById("sheet-bus-speed");

    if (busId === 101) {
        numText.innerText = "WP-ND-8432";
        nameText.innerText = "Privelgo Express Blue • Route 138";
        speedText.innerText = "35 km/h";
    } else {
        numText.innerText = "WP-NB-5544";
        nameText.innerText = "Lanka Luxury Star • Route 100";
        speedText.innerText = "28 km/h";
    }

    renderReviews();
    sheet.style.display = "block";
}

function closeBusDetails() {
    document.getElementById("bus-details-sheet").style.display = "none";
}

function renderReviews() {
    const feed = document.getElementById("mobile-reviews-feed");
    feed.innerHTML = "";
    
    const activeReviews = reviews.filter(r => r.status === "approved");
    if (activeReviews.length === 0) {
        feed.innerHTML = '<p style="font-size:9px; color:#999; text-align:center;">No feedback posted yet.</p>';
        return;
    }

    activeReviews.forEach(r => {
        const item = document.createElement("div");
        item.className = "review-item";
        item.innerHTML = `
            <header>
                <span>${r.user}</span>
                <span>⭐ ${r.rating}</span>
            </header>
            <p>${r.comment}</p>
        `;
        feed.appendChild(item);
    });

    // Also populate review moderator queue in admin
    renderAdminReviewsQueue();
}

function submitPassengerReview() {
    const comment = document.getElementById("review-comment").value.trim();
    const rating = parseInt(document.querySelector(".rating-stars-input").getAttribute("data-selected-rating")) || 5;

    if (!comment) {
        alert("Please write a feedback comment.");
        return;
    }

    const newRev = {
        id: reviews.length + 1,
        user: "Alex Dev (You)",
        rating: rating,
        comment: comment,
        status: "pending" // Admin must approve!
    };

    reviews.unshift(newRev);
    document.getElementById("review-comment").value = "";

    // Reward points logic
    rewardPoints += 15;
    document.getElementById("reward-points-val").innerText = rewardPoints;

    alert("Review submitted to Operator portal moderation queue! Earned +15 Privelgo points! 🏆");
    renderAdminReviewsQueue();
}

function triggerSosPassenger() {
    const confirmSOS = confirm("Flag driver performance/hazard? This alerts operator emergency services.");
    if (confirmSOS) {
        triggerSosComplaint("Passenger Alex Dev", "WP-ND-8432", "High speed weaving reported by rider.");
    }
}

function triggerSosComplaint(reporter, vehicle, desc) {
    const incFeed = document.getElementById("admin-incidents-feed");
    const emptyMsg = incFeed.querySelector(".feed-empty");
    if (emptyMsg) emptyMsg.remove();

    const item = document.createElement("div");
    item.className = "complaint-item";
    item.innerHTML = `
        <header>
            <span>🚨 SOS INCIDENT TRIGGER</span>
            <span>PENDING</span>
        </header>
        <p><strong>Bus:</strong> ${vehicle} • <strong>Reporter:</strong> ${reporter}</p>
        <p>${desc}</p>
        <footer>Just now</footer>
    `;

    incFeed.insertBefore(item, incFeed.firstChild);

    // Update Admin badges
    const sosCount = document.getElementById("admin-active-complaints");
    sosCount.innerText = parseInt(sosCount.innerText) + 1;
}

// ==========================================
// 5. OPERATOR & FLEET ADMIN MODERATION
// ==========================================
function renderAdminReviewsQueue() {
    const adminFeed = document.getElementById("admin-reviews-feed");
    adminFeed.innerHTML = "";

    const pending = reviews.filter(r => r.status === "pending");
    if (pending.length === 0) {
        adminFeed.innerHTML = '<div class="feed-empty">No reviews in moderation queue.</div>';
        return;
    }

    pending.forEach(r => {
        const row = document.createElement("div");
        row.className = "moderation-row";
        row.innerHTML = `
            <div class="mod-header">
                <span>${r.user}</span>
                <span>⭐ ${r.rating}</span>
            </div>
            <div class="mod-body">"${r.comment}"</div>
            <div class="mod-actions">
                <button class="btn-reject" onclick="moderateReview(${r.id}, 'rejected')">Reject</button>
                <button class="btn-approve" onclick="moderateReview(${r.id}, 'approved')">Approve</button>
            </div>
        `;
        adminFeed.appendChild(row);
    });
}

function moderateReview(id, status) {
    const revIdx = reviews.findIndex(r => r.id === id);
    if (revIdx !== -1) {
        reviews[revIdx].status = status;
        renderReviews();
        alert(`Review ${status === 'approved' ? 'approved' : 'rejected'}.`);
    }
}

function updateAdminMetrics() {
    const activeBusesCount = document.getElementById("admin-active-buses");
    const avgOcc = document.getElementById("admin-avg-occupancy");

    activeBusesCount.innerText = driverTripActive ? "2" : "1";
    
    // Compute avg occupancy
    const pass1 = driverTripActive ? parseInt(document.getElementById("driver-passenger-count").innerText) : 0;
    const pass2 = 35; // Bus 102 mock occupancy
    const totalCap = driverTripActive ? 82 : 40;
    const calculatedOcc = Math.round(((pass1 + pass2) / totalCap) * 100);
    avgOcc.innerText = `${calculatedOcc}%`;
}

// ==========================================
// 6. AI TRAVEL ASSISTANT SIMULATOR
// ==========================================
function handleAiAssistantQuery() {
    const queryInput = document.getElementById("assistant-query");
    const q = queryInput.value.trim().toLowerCase();
    if (!q) return;

    const bubble = document.getElementById("assistant-bubble");
    bubble.innerText = "Thinking...";

    setTimeout(() => {
        let reply = "I'm sorry, I couldn't understand that request. Try asking about which bus to take, fares, delays, or crowdedness levels!";
        
        if (q.includes("which bus") || q.includes("how to go") || q.includes("route")) {
            reply = "To go from Colombo Central to Mount Lavinia, board Bus 100 at Colombo Central. It takes approximately 40 minutes.";
        } else if (q.includes("cheapest") || q.includes("cost") || q.includes("fare")) {
            reply = "Standard base fare is 40 LKR. Taking Bus 138 is the cheapest route today, and you can apply your student discount for 50% off.";
        } else if (q.includes("crowd") || q.includes("seat") || q.includes("occupancy")) {
            const count = parseInt(document.getElementById("driver-passenger-count").innerText);
            reply = `Live occupancy report: Bus 138 currently has ${count} passengers (Seats Available 🟢). Bus 100 has 35 passengers (Moderately Crowded 🟡).`;
        } else if (q.includes("late") || q.includes("delay") || q.includes("traffic")) {
            const delayVal = document.getElementById("driver-delay-status").value;
            if (parseInt(delayVal) > 0) {
                reply = `Bus 138 reports a ${delayVal} mins delay due to road congestion. Bus 100 is running on schedule.`;
            } else {
                reply = "Currently, all active buses are running on time! 🟢";
            }
        }

        bubble.innerText = reply;
        queryInput.value = "";
    }, 800);
}
