// Map initialization and location data visualization
class LocationMap {
    constructor() {
        this.map = null;
        this.markers = [];
        this.markerLayer = null;
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
        this.markerLayer = L.layerGroup().addTo(this.map);
        this._hasUserInteracted = false;
        this._hasFitOnce = false;
        this.map.on('zoomstart dragstart movestart', () => { this._hasUserInteracted = true; });

        // Add OpenStreetMap tiles
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
            maxZoom: 18
        }).addTo(this.map);

        // Add scale update listeners for both zoom and pan operations
        this.map.on('zoomend moveend', () => {
            this.updateScaleIndicator();
        });
    }

    async loadLocations() {
        try {
            const response = await fetch('/locations', {
                credentials: 'include',
                cache: 'no-store',
                headers: { 'Accept': 'application/json' }
            });

            if (!response.ok) {
                if (response.status === 401) {
                    throw new Error('Authentication required. Please ensure your API key cookie is set.');
                }
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const data = await response.json();
            this.locations = data.locations;
            
            this.clearError();
            this.hideLoading();
            this.updateStats(data);
            this.addMarkersToMap();
            this.fitMapToMarkers();
            this.updateScaleIndicator();

        } catch (error) {
            console.error('Error loading locations:', error);
            this.showError(error.message);
            this.hideLoading();
        }
    }

    clearError() {
        const el = document.getElementById('errorMsg');
        if (!el) return;
        el.textContent = '';
        el.classList.remove('show');
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
        if (this.markerLayer) this.markerLayer.clearLayers();
        this.markers = [];

        if (this.locations.length === 0) {
            this.showError('No location data available');
            return;
        }

        // Find min/max request counts for scaling (single pass; no spread)
        let minRequests = Number.POSITIVE_INFINITY;
        let maxRequests = Number.NEGATIVE_INFINITY;
        for (const loc of this.locations) {
            const v = Number(loc.request_count) || 0;
            if (v < minRequests) minRequests = v;
            if (v > maxRequests) maxRequests = v;
        }
        if (!isFinite(minRequests)) { minRequests = 0; maxRequests = 0; }

        this.locations.forEach(location => {
            const marker = this.createMarker(location, minRequests, maxRequests);
            marker.addTo(this.markerLayer);
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
        marker.bindPopup(popupContent, {
            closeOnClick: true,
            autoClose: true
        });

        // Add hover effects for visual feedback only
        marker.on('mouseover', function(e) {
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

        // Ensure popup only opens on click (override default hover behavior)

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
        const diffMs = Math.max(0, now - date);
        const diffSeconds = Math.floor(diffMs / 1000);
        const diffMinutes = Math.floor(diffSeconds / 60);
        const diffHours = Math.floor(diffMinutes / 60);
        const diffDays = Math.floor(diffHours / 24);

        if (diffSeconds < 60) {
            return `${diffSeconds} second${diffSeconds !== 1 ? 's' : ''} ago`;
        } else if (diffMinutes < 60) {
            return `${diffMinutes} minute${diffMinutes !== 1 ? 's' : ''} ago`;
        } else if (diffHours < 24) {
            return `${diffHours} hour${diffHours !== 1 ? 's' : ''} ago`;
        } else if (diffDays === 1) {
            return '1 day ago';
        } else {
            return `${diffDays} day${diffDays !== 1 ? 's' : ''} ago`;
        }
    }

    fitMapToMarkers() {
        if (this.markers.length === 0) return;
        if (this._hasUserInteracted || this._hasFitOnce) return;

        if (this.markers.length === 1) {
            // If only one marker, center on it with a reasonable zoom
            const marker = this.markers[0];
            this.map.setView(marker.getLatLng(), 10);
        } else {
            // Fit bounds to show all markers
            const group = new L.featureGroup(this.markers);
            this.map.fitBounds(group.getBounds().pad(0.1));
        }
        this._hasFitOnce = true;
        
        // Scale indicator will be updated automatically via the moveend event
    }

    updateScaleIndicator() {
        const scaleElement = document.getElementById('scaleText');
        if (!scaleElement) return;
        
        // Get the current map center and bounds for calculation
        const center = this.map.getCenter();
        const zoom = this.map.getZoom();
        
        // Calculate the distance represented by 40 pixels using Web Mercator projection
        // At the equator, one degree of longitude equals approximately 111,320 meters
        // Leaflet's distanceTo() method automatically accounts for latitude adjustment and projection
        const pixelWidth = 40; // The ruler width in pixels
        
        // Get the pixel bounds of the ruler
        const mapSize = this.map.getSize();
        const containerPoint1 = L.point(mapSize.x / 2, mapSize.y / 2);
        const containerPoint2 = L.point(mapSize.x / 2 + pixelWidth, mapSize.y / 2);
        
        // Convert pixel points to geographic coordinates
        const latLng1 = this.map.containerPointToLatLng(containerPoint1);
        const latLng2 = this.map.containerPointToLatLng(containerPoint2);
        
        // Calculate the distance between these points using Leaflet's distance method
        // This accounts for the Web Mercator projection and latitude adjustment
        const distanceInMeters = latLng1.distanceTo(latLng2);
        
        let scaleText = '';
        let displayDistance = distanceInMeters;
        
        // Format the distance with appropriate units and precision
        if (distanceInMeters >= 1000) {
            displayDistance = distanceInMeters / 1000;
            if (displayDistance >= 100) {
                scaleText = `${Math.round(displayDistance)}km`;
            } else if (displayDistance >= 10) {
                scaleText = `${displayDistance.toFixed(1)}km`;
            } else {
                scaleText = `${displayDistance.toFixed(2)}km`;
            }
        } else {
            if (distanceInMeters >= 100) {
                scaleText = `${Math.round(distanceInMeters)}m`;
            } else if (distanceInMeters >= 10) {
                scaleText = `${distanceInMeters.toFixed(1)}m`;
            } else {
                scaleText = `${distanceInMeters.toFixed(2)}m`;
            }
        }
        
        scaleElement.textContent = scaleText;
    }

    hideLoading() {
        const el = document.getElementById('loading');
        if (el) el.classList.add('hidden');
    }

    showError(message) {
        const errorElement = document.getElementById('errorMsg');
        if (!errorElement) return;
        errorElement.textContent = message;
        errorElement.classList.add('show');
    }
}

// Initialize the map when the page loads
let locationMapInstance;
document.addEventListener('DOMContentLoaded', () => {
    locationMapInstance = new LocationMap();
    window._locationMap = locationMapInstance; // optional global for debugging
});

// Add refresh functionality
document.addEventListener('keydown', (e) => {
    if (e.key === 'r' && (e.ctrlKey || e.metaKey)) {
        const ae = document.activeElement;
        const tag = ae && ae.tagName;
        const inEditable = ae?.isContentEditable || ['INPUT','TEXTAREA','SELECT'].includes(tag);
        if (inEditable) return;
        e.preventDefault();
        if (locationMapInstance && !locationMapInstance._loading) {
            locationMapInstance.loadLocations();
        }
    }
});

// Auto-refresh every 5 minutes
setInterval(() => {
    if (document.visibilityState === 'visible' && locationMapInstance && !locationMapInstance._loading && navigator.onLine) {
        locationMapInstance.loadLocations();
    }
}, 5 * 60 * 1000);
