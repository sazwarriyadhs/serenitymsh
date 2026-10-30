import Nav from './components/Nav.jsx'
import Hero from './components/Hero.jsx'
import Numbers from './components/Numbers.jsx'
import BentoGrid from './components/BentoGrid.jsx'
import DualPath from './components/DualPath.jsx'
import EventTypes from './components/EventTypes.jsx'
import Testimonial from './components/Testimonial.jsx'
import MapSection from './components/MapSection.jsx'
import InquiryForm from './components/InquiryForm.jsx'
import Footer from './components/Footer.jsx'

export default function App() {
  return (
    <div className="min-h-screen bg-cream-100">
      <Nav />
      <Hero />
      <Numbers />
      <BentoGrid />
      <DualPath />
      <EventTypes />
      <Testimonial />
      <MapSection />
      <InquiryForm />
      <Footer />
    </div>
  )
}