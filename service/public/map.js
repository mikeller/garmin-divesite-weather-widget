// Map initialization and location data visualization
class LocationMap {
    constructor() {
        this.map = null;
        this.markers = [];
        this.locations = [];
        this.init();
    }

    init() {
        this.initMap();
        this.loadLocations();
    }

    initMap() {
        // Initialize the map centered on the world
        this.map = L.map('map').setView([20, 0], 2);

        // Add OpenStreetMap tiles
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
            maxZoom: 18
        }).addTo(this.map);
    }

    async loadLocations() {
        try {
            const response = await fetch('/locations', {
                credentials: 'include', // Include cookies
                headers: {
                    'Accept': 'application/json'
                }
            });

            if (!response.ok) {
                if (response.status === 401) {
                    throw new Error('Authentication required. Please ensure your API key cookie is set.');
                }
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const data = await response.json();
            this.locations = data.locations;
            
            this.hideLoading();
            this.updateStats(data);
            this.addMarkersToMap();
            this.fitMapToMarkers();

        } catch (error) {
            console.error('Error loading locations:', error);
            this.showError(error.message);
            this.hideLoading();
        }
    }

    updateStats(data) {
        document.getElementById('totalLocations').textContent = data.total_unique_locations.toLocaleString();
        document.getElementById('totalRequests').textContent = data.total_requests_all_locations.toLocaleString();
        
        const avgRequests = data.total_unique_locations > 0 
            ? Math.round(data.total_requests_all_locations / data.total_unique_locations * 10) / 10 
            : 0;
        document.getElementById('avgRequests').textContent = avgRequests.toLocaleString();
    }

    addMarkersToMap() {
        // Clear existing markers
        this.markers.forEach(marker => this.map.removeLayer(marker));
        this.markers = [];

        if (this.locations.length === 0) {
            this.showError('No location data available');
            return;
        }

        // Find min/max request counts for scaling
        const requestCounts = this.locations.map(loc => loc.request_count);
        const minRequests = Math.min(...requestCounts);
        const maxRequests = Math.max(...requestCounts);

        this.locations.forEach(location => {
            const marker = this.createMarker(location, minRequests, maxRequests);
            marker.addTo(this.map);
            this.markers.push(marker);
        });
    }

    createMarker(location, minRequests, maxRequests) {
        // Calculate marker size based on request count
        const size = this.calculateMarkerSize(location.request_count, minRequests, maxRequests);
        const opacity = this.calculateMarkerOpacity(location.request_count, minRequests, maxRequests);

        // Create custom marker
        const marker = L.circleMarker([location.latitude, location.longitude], {
            radius: size,
            fillColor: '#667eea',
            color: '#4c63d2',
            weight: 2,
            opacity: 0.9,
            fillOpacity: opacity
        });

        // Create popup content
        const popupContent = this.createPopupContent(location);
        marker.bindPopup(popupContent);

        // Add hover effects
        marker.on('mouseover', function(e) {
            this.openPopup();
            this.setStyle({
                weight: 3,
                fillOpacity: Math.min(opacity + 0.2, 1)
            });
        });

        marker.on('mouseout', function(e) {
            this.setStyle({
                weight: 2,
                fillOpacity: opacity
            });
        });

        return marker;
    }

    calculateMarkerSize(requestCount, minRequests, maxRequests) {
        // Base size between 8 and 25 pixels
        const minSize = 8;
        const maxSize = 25;
        
        if (minRequests === maxRequests) {
            return minSize + (maxSize - minSize) / 2;
        }

        const normalizedCount = (requestCount - minRequests) / (maxRequests - minRequests);
        return minSize + (normalizedCount * (maxSize - minSize));
    }

    calculateMarkerOpacity(requestCount, minRequests, maxRequests) {
        // Opacity between 0.3 and 0.8
        const minOpacity = 0.3;
        const maxOpacity = 0.8;
        
        if (minRequests === maxRequests) {
            return minOpacity + (maxOpacity - minOpacity) / 2;
        }

        const normalizedCount = (requestCount - minRequests) / (maxRequests - minRequests);
        return minOpacity + (normalizedCount * (maxOpacity - minOpacity));
    }

    createPopupContent(location) {
        const lastRequested = new Date(location.last_requested);
        const lastRequestedFormatted = lastRequested.toLocaleString();
        const timeAgo = this.formatTimeAgo(lastRequested);

        return `
            <div class="location-popup">
                <h3>📍 Location Details</h3>
                <div class="detail">
                    <span class="label">Coordinates:</span> 
                    ${location.latitude.toFixed(3)}, ${location.longitude.toFixed(3)}
                </div>
                <div class="detail">
                    <span class="label">Requests:</span> 
                    ${location.request_count.toLocaleString()}
                </div>
                <div class="detail">
                    <span class="label">Last Requested:</span> 
                    ${lastRequestedFormatted}
                </div>
                <div class="detail">
                    <span class="label">Time Ago:</span> 
                    ${timeAgo}
                </div>
            </div>
        `;
    }

    formatTimeAgo(date) {
        const now = new Date();
        const diffMs = now - date;
        const diffSeconds = Math.floor(diffMs / 1000);
        const diffMinutes = Math.floor(diffSeconds / 60);
        const diffHours = Math.floor(diffMinutes / 60);
        const diffDays = Math.floor(diffHours / 24);

        if (diffSeconds < 60) {
            return `${diffSeconds} seconds ago`;
        } else if (diffMinutes < 60) {
            return `${diffMinutes} minutes ago`;
        } else if (diffHours < 24) {
            return `${diffHours} hours ago`;
        } else if (diffDays === 1) {
            return '1 day ago';
        } else {
            return `${diffDays} days ago`;
        }
    }

    fitMapToMarkers() {
        if (this.markers.length === 0) return;

        if (this.markers.length === 1) {
            // If only one marker, center on it with a reasonable zoom
            const marker = this.markers[0];
            this.map.setView(marker.getLatLng(), 10);
        } else {
            // Fit bounds to show all markers
            const group = new L.featureGroup(this.markers);
            this.map.fitBounds(group.getBounds().pad(0.1));
        }
    }

    hideLoading() {
        document.getElementById('loading').classList.add('hidden');
    }

    showError(message) {
        const errorElement = document.getElementById('errorMsg');
        errorElement.textContent = message;
        errorElement.classList.add('show');
    }
}

// Initialize the map when the page loads
document.addEventListener('DOMContentLoaded', () => {
    new LocationMap();
});

// Add refresh functionality
document.addEventListener('keydown', (e) => {
    if (e.key === 'r' && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        location.reload();
    }
});

// Auto-refresh every 5 minutes
setInterval(() => {
    if (document.visibilityState === 'visible') {
        location.reload();
    }
}, 5 * 60 * 1000);