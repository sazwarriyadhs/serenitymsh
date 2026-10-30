import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import { useEffect } from 'react'
import L from 'leaflet'

// Fix for default marker icons in React Leaflet
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
    iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

export default function MapSection() {
  // Koordinat IPB International Convention Center (Bogor)
  const position = [-6.5889, 106.8066] 

  return (
    <section id="location" className="py-24 px-6 bg-cream-200 relative overflow-hidden">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="font-serif text-4xl md:text-5xl text-ink-900">Find Us</h2>
          <p className="mt-4 text-ink-700/70">Strategically located in the heart of Bogor's academic and business district.</p>
        </div>
        
        <div className="bg-white p-2 rounded-3xl shadow-2xl border border-gold-400/20 overflow-hidden h-[500px] relative z-0">
          <MapContainer 
            center={position} 
            zoom={15} 
            scrollWheelZoom={false}
            className="w-full h-full rounded-2xl"
          >
            <TileLayer
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />
            <Marker position={position}>
              <Popup>
                <strong className="font-serif text-lg">IPB International Convention Center</strong><br/>
                Jl. Raya Pajajaran, Bogor, Jawa Barat
              </Popup>
            </Marker>
          </MapContainer>
        </div>
      </div>
    </section>
  )
}