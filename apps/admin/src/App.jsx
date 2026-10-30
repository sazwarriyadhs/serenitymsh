import { useState, useEffect } from 'react';
import './App.css';

const NAVIGATION = [
  { group: 'EXECUTIVE', items: [{ id: 'dashboard', label: 'Dashboard', icon: '◈' }, { id: 'analytics', label: 'Analytics & KPI', icon: '▤' }, { id: 'reports', label: 'Reports', icon: '▧' }] },
  { group: 'FRONT OFFICE', items: [{ id: 'reservations', label: 'Reservations', icon: '▦' }, { id: 'rooms', label: 'Room Management', icon: '▣' }, { id: 'guests', label: 'Guests & CRM', icon: '♙' }, { id: 'housekeeping', label: 'Housekeeping', icon: '♧' }] },
  { group: 'CONVENTION', items: [{ id: 'venues', label: 'Venue Management', icon: '♜' }, { id: 'events', label: 'Event Calendar', icon: '▦' }, { id: 'quotations', label: 'Quotations', icon: '✎' }] },
  { group: 'COMMERCIAL', items: [{ id: 'rates', label: 'Revenue Mgmt', icon: '◇' }, { id: 'pos', label: 'POS & Billing', icon: '▤' }] },
  { group: 'BACK OFFICE', items: [{ id: 'finance', label: 'Finance', icon: '▤' }, { id: 'hr', label: 'HR & Staff', icon: '♙' }, { id: 'inventory', label: 'Inventory', icon: '▦' }, { id: 'purchasing', label: 'Purchasing', icon: '◉' }] },
  { group: 'SYSTEM', items: [{ id: 'users', label: 'Users & Roles', icon: '♙' }, { id: 'integrations', label: 'Integrations', icon: '⇄' }, { id: 'audit', label: 'Audit Logs', icon: '▤' }, { id: 'settings', label: 'Settings', icon: '⚙' }] }
];

function Dashboard() {
  const [metrics, setMetrics] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchData = () => {
    setIsLoading(true);
    setError(null);
    fetch('/api/dashboard')
      .then(res => { if (!res.ok) throw new Error('Backend offline'); return res.json(); })
      .then(data => { setMetrics(data); setIsLoading(false); })
      .catch(err => { setError(err.message); setIsLoading(false); });
  };

  useEffect(() => { fetchData(); }, []);

  return (
    <>
      <div className="welcome-section">
        <div>
          <h2 className="welcome-title">GOOD AFTERNOON, ADMIN</h2>
          <p className="welcome-subtitle">Welcome to your hospitality command center.</p>
          <p className="date-subtitle">{new Date().toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}</p>
        </div>
        <div className="action-buttons">
          <button className="btn-outline">TODAY ▾</button>
          <button className="btn-outline" onClick={fetchData}>REFRESH ↻</button>
        </div>
      </div>
      <hr className="divider" />
      <div className="section-title">EXECUTIVE PERFORMANCE</div>
      <div className="kpi-grid">
        <div className="kpi-card">
          <div className="kpi-label">OCCUPANCY</div>
          <div className="kpi-value">{isLoading ? '...' : `${metrics?.occupancy_percentage || 0}%`}</div>
          <div className="demo-tag">LIVE API</div>
          <div className="kpi-desc">Occupied rooms</div>
        </div>
        <div className="kpi-card">
          <div className="kpi-label">ROOMS AVAILABLE</div>
          <div className="kpi-value">{isLoading ? '...' : (metrics?.total_rooms ? 33 : 0)}</div>
          <div className="demo-tag">SAMPLE</div>
          <div className="kpi-desc">Out of 150</div>
        </div>
        <div className="kpi-card">
          <div className="kpi-label">ARRIVALS TODAY</div>
          <div className="kpi-value">24</div>
          <div className="demo-tag">SAMPLE</div>
          <div className="kpi-desc">Expected guests</div>
        </div>
        <div className="kpi-card">
          <div className="kpi-label">REVENUE TODAY</div>
          <div className="kpi-value">Rp 48.6M</div>
          <div className="demo-tag">SAMPLE</div>
          <div className="kpi-desc">Gross revenue</div>
        </div>
      </div>
      <div className="mid-grid">
        <div className="panel">
          <div className="panel-title">PERFORMANCE OVERVIEW</div>
          <div className="demo-tag">SAMPLE VISUALIZATION</div>
          <div className="chart-placeholder" style={{ display: 'flex', alignItems: 'flex-end', gap: '8px', padding: '20px', justifyContent: 'space-around' }}>
            <div style={{ width: '30px', background: '#5C1A1B', height: '40%', borderRadius: '4px 4px 0 0' }}></div>
            <div style={{ width: '30px', background: '#5C1A1B', height: '60%', borderRadius: '4px 4px 0 0' }}></div>
            <div style={{ width: '30px', background: '#5C1A1B', height: '80%', borderRadius: '4px 4px 0 0' }}></div>
            <div style={{ width: '30px', background: '#D4AF37', height: '100%', borderRadius: '4px 4px 0 0' }}></div>
            <div style={{ width: '30px', background: '#5C1A1B', height: '70%', borderRadius: '4px 4px 0 0' }}></div>
            <div style={{ width: '30px', background: '#5C1A1B', height: '50%', borderRadius: '4px 4px 0 0' }}></div>
            <div style={{ width: '30px', background: '#5C1A1B', height: '90%', borderRadius: '4px 4px 0 0' }}></div>
          </div>
        </div>
        <div className="panel">
          <div className="panel-title">TODAY'S OPERATIONS</div>
          <div className="ops-list">
            <div className="ops-row"><span>ARRIVALS</span><strong>24</strong></div>
            <div className="progress-bar"><div className="progress-fill" style={{ width: '60%' }}></div></div>
            <div className="ops-row"><span>DEPARTURES</span><strong>18</strong></div>
            <div className="progress-bar"><div className="progress-fill" style={{ width: '40%' }}></div></div>
            <div className="ops-row"><span>IN-HOUSE GUESTS</span><strong>96</strong></div>
            <div className="progress-bar"><div className="progress-fill" style={{ width: '80%' }}></div></div>
          </div>
        </div>
      </div>
    </>
  );
}

function AnalyticsPage() {
  const analyticsKpi = [
    { label: 'RevPAR', value: 'Rp 850.000', trend: '+5.2%', isUp: true },
    { label: 'ADR (Avg Daily Rate)', value: 'Rp 1.150.000', trend: '+2.1%', isUp: true },
    { label: 'Total Revenue (YTD)', value: 'Rp 12.5B', trend: '+15.4%', isUp: true },
    { label: 'Guest Satisfaction', value: '4.8 / 5.0', trend: '-0.1%', isUp: false },
  ];

  return (
    <>
      <div className="welcome-section">
        <div>
          <h2 className="welcome-title">ANALYTICS & KPI</h2>
          <p className="welcome-subtitle">Deep dive into your property's financial and operational performance.</p>
        </div>
        <div className="action-buttons">
          <select className="btn-outline" style={{ appearance: 'none' }}>
            <option>Last 30 Days</option>
            <option>This Quarter</option>
            <option>Year to Date</option>
          </select>
          <button className="btn-primary">Export Report</button>
        </div>
      </div>
      <hr className="divider" />
      
      <div className="section-title">FINANCIAL METRICS (SAMPLE DATA)</div>
      <div className="kpi-grid">
        {analyticsKpi.map((kpi, i) => (
          <div key={i} className="kpi-card">
            <div className="kpi-label">{kpi.label}</div>
            <div className="kpi-value" style={{ fontSize: '26px' }}>{kpi.value}</div>
            <div style={{ fontSize: '11px', fontWeight: 'bold', color: kpi.isUp ? 'var(--success)' : 'var(--danger)' }}>
              {kpi.trend} vs prev period
            </div>
          </div>
        ))}
      </div>

      <div className="mid-grid" style={{ marginTop: '24px', gridTemplateColumns: '1fr 1fr' }}>
        <div className="panel">
          <div className="panel-title">REVENUE TREND (6 MONTHS)</div>
          <div className="chart-placeholder" style={{ height: '220px', display: 'flex', alignItems: 'flex-end', gap: '8px', padding: '20px', justifyContent: 'space-around' }}>
            <div style={{ width: '40px', background: '#5C1A1B', height: '45%', borderRadius: '4px 4px 0 0' }}></div>
            <div style={{ width: '40px', background: '#5C1A1B', height: '55%', borderRadius: '4px 4px 0 0' }}></div>
            <div style={{ width: '40px', background: '#5C1A1B', height: '70%', borderRadius: '4px 4px 0 0' }}></div>
            <div style={{ width: '40px', background: '#D4AF37', height: '85%', borderRadius: '4px 4px 0 0' }}></div>
            <div style={{ width: '40px', background: '#5C1A1B', height: '60%', borderRadius: '4px 4px 0 0' }}></div>
            <div style={{ width: '40px', background: '#5C1A1B', height: '95%', borderRadius: '4px 4px 0 0' }}></div>
          </div>
        </div>
        
        <div className="panel">
          <div className="panel-title">OCCUPANCY BY ROOM TYPE</div>
          <div className="ops-list">
            <div className="ops-row"><span>Deluxe King</span><strong>85%</strong></div>
            <div className="progress-bar"><div className="progress-fill" style={{width: '85%'}}></div></div>
            <div className="ops-row"><span>Deluxe Twin</span><strong>70%</strong></div>
            <div className="progress-bar"><div className="progress-fill" style={{width: '70%'}}></div></div>
            <div className="ops-row"><span>Executive Suite</span><strong>92%</strong></div>
            <div className="progress-bar"><div className="progress-fill" style={{width: '92%'}}></div></div>
            <div className="ops-row"><span>Presidential Suite</span><strong>45%</strong></div>
            <div className="progress-bar"><div className="progress-fill" style={{width: '45%'}}></div></div>
          </div>
        </div>
      </div>
    </>
  );
}

function DataPage({ title, description, columns, data, actionLabel = "Add New" }) {
  return (
    <div className="generic-page">
      <div className="page-header">
        <div>
          <h2 className="page-header-title">{title}</h2>
          <p className="page-header-desc">{description}</p>
        </div>
        <button className="btn-primary">{actionLabel} +</button>
      </div>
      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              {columns.map((col, i) => <th key={i}>{col}</th>)}
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {data.map((row, i) => (
              <tr key={i}>
                {columns.map((col, j) => <td key={j}>{row[j]}</td>)}
                <td>
                  <button className="btn-action">Edit</button>
                  <button className="btn-action danger">Delete</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

const mockReservations = [
  ['IPB-00123', 'Alexander Lee', 'Deluxe King', '2026-10-25', '2026-10-27', 'Confirmed'],
  ['IPB-00124', 'Sarah Mitchell', 'Executive Suite', '2026-10-26', '2026-10-28', 'Pending'],
  ['IPB-00125', 'Robert Kim', 'Deluxe Twin', '2026-10-25', '2026-10-26', 'Checked In'],
  ['IPB-00126', 'Jessica Davis', 'Presidential Suite', '2026-10-27', '2026-10-30', 'Confirmed'],
];

const mockRooms = [
  ['204', 'Deluxe King', '2', 'Occupied', 'Clean'],
  ['301', 'Executive Suite', '3', 'Available', 'Clean'],
  ['108', 'Deluxe Twin', '1', 'Cleaning', 'In Progress'],
  ['501', 'Presidential Suite', '5', 'Occupied', 'Clean'],
];

const mockGuests = [
  ['Alexander Lee', 'alex@example.com', '+62 812-3456-7890', 'Gold Member', '2026-10-20'],
  ['Sarah Mitchell', 'sarah@example.com', '+62 811-2345-6789', 'Platinum', '2026-09-15'],
  ['Robert Kim', 'robert@example.com', '+62 813-4567-8901', 'Silver', '2026-10-10'],
  ['Jessica Davis', 'jessica@example.com', '+62 815-6789-0123', 'Basic', '2026-08-01'],
];

const mockHousekeeping = [
  ['TSK-01', 'Room 108', 'Budi', 'In Progress', 'High'],
  ['TSK-02', 'Room 204', 'Ani', 'Completed', 'Normal'],
  ['TSK-03', 'Lobby Area', 'Citra', 'Pending', 'High'],
  ['TSK-04', 'Room 301', 'Dewi', 'Completed', 'Low'],
];

const mockVenues = [
  ['Grand Ballroom', '1500 Pax', 'Theater', 'Rp 50.000.000', 'Available'],
  ['Meeting Room A', '100 Pax', 'Classroom', 'Rp 5.000.000', 'Available'],
  ['Meeting Room B', '50 Pax', 'U-Shape', 'Rp 3.000.000', 'Booked'],
  ['Exhibition Hall', '2000 Pax', 'Standing', 'Rp 75.000.000', 'Available'],
];

const mockEvents = [
  ['Global Agricultural Summit', 'Ministry of Agri', '2026-11-10', 'Grand Ballroom', 'Confirmed'],
  ['IPB Alumni Reunion', 'IPB Alumni', '2026-12-05', 'Exhibition Hall', 'Pending'],
  ['Tech Conference 2026', 'TechCorp', '2026-11-20', 'Meeting Room A', 'Confirmed'],
];

const mockQuotations = [
  ['QUO-001', 'Ministry of Agri', 'Conference', 'Rp 150.000.000', 'Sent'],
  ['QUO-002', 'TechCorp', 'Seminar', 'Rp 45.000.000', 'Accepted'],
  ['QUO-003', 'Wedding Planner', 'Wedding', 'Rp 200.000.000', 'Draft'],
];

const mockRates = [
  ['2026-10-25', 'Deluxe King', 'Rp 1.200.000', '10', '2 Nights'],
  ['2026-10-25', 'Executive Suite', 'Rp 2.500.000', '5', '2 Nights'],
  ['2026-10-26', 'Deluxe King', 'Rp 1.200.000', '15', '1 Night'],
  ['2026-10-26', 'Deluxe Twin', 'Rp 1.000.000', '8', '1 Night'],
];

const mockPos = [
  ['TRX-1001', 'Restaurant', '2x Nasi Goreng', 'Rp 150.000', 'Cash'],
  ['TRX-1002', 'Spa', 'Massage 60m', 'Rp 350.000', 'Card'],
  ['TRX-1003', 'Cafe', '3x Coffee', 'Rp 90.000', 'Room Charge'],
];

const mockFinance = [
  ['INV-2026-001', 'Alexander Lee', 'Rp 2.400.000', '2026-10-25', 'Paid'],
  ['INV-2026-002', 'TechCorp', 'Rp 45.000.000', '2026-10-24', 'Pending'],
  ['INV-2026-003', 'Sarah Mitchell', 'Rp 5.000.000', '2026-10-23', 'Paid'],
];

const mockUsers = [
  ['Admin Utama', 'admin@serenityhms.com', 'Super Admin', 'IT', 'Active'],
  ['Front Desk 1', 'fo1@serenityhms.com', 'Front Office', 'Front Office', 'Active'],
  ['Finance Staff', 'finance@serenityhms.com', 'Finance', 'Accounting', 'Active'],
  ['Housekeeping 1', 'hk1@serenityhms.com', 'Housekeeping', 'Housekeeping', 'Inactive'],
];

const mockSettings = [
  ['hotel_name', 'IPB Convention Hotel', 'Display name', '2026-10-01'],
  ['checkin_time', '14:00', 'Standard check-in', '2026-10-01'],
  ['checkout_time', '12:00', 'Standard check-out', '2026-10-01'],
  ['currency', 'IDR', 'Default currency', '2026-10-01'],
];

const mockHR = [
  ['Budi Santoso', 'Front Desk', 'Shift Pagi', 'Hadir', '08:00 - 16:00'],
  ['Siti Aminah', 'Housekeeping', 'Shift Siang', 'Hadir', '14:00 - 22:00'],
  ['Andi Wijaya', 'F&B', 'Shift Malam', 'Izin', '22:00 - 06:00'],
  ['Citra Dewi', 'Finance', 'Office Hours', 'Hadir', '09:00 - 17:00'],
];

const mockInventory = [
  ['INV-01', 'Sabun Mandi', 'Housekeeping', 500, 'pcs'],
  ['INV-02', 'Handuk Mandi', 'Housekeeping', 150, 'pcs'],
  ['INV-03', 'Beras Premium', 'F&B', 200, 'kg'],
  ['INV-04', 'Kertas HVS A4', 'Admin', 50, 'rim'],
];

const mockPurchasing = [
  ['PO-2026-01', 'PT Sumber Makmur', 'Beras & Sayur', 'Rp 15.000.000', 'Approved'],
  ['PO-2026-02', 'CV Bersih Jaya', 'Chemical Cleaning', 'Rp 5.500.000', 'Pending'],
  ['PO-2026-03', 'PT Teknologi ID', 'Laptop & Printer', 'Rp 35.000.000', 'Delivered'],
];

const mockIntegrations = [
  ['PMS', 'Opera', 'Connected', '2026-10-20'],
  ['OTA', 'Booking.com', 'Pending Config', '-'],
  ['Payment', 'Midtrans', 'Connected', '2026-10-15'],
  ['Accounting', 'Accurate', 'Not Connected', '-'],
];

const mockAudit = [
  ['2026-10-24 14:32', 'Admin Utama', 'LOGIN', 'Successful login from IP 192.168.1.5'],
  ['2026-10-24 14:15', 'Budi Santoso', 'CREATE_BOOKING', 'Booking ID: IPB-00126'],
  ['2026-10-24 13:50', 'Siti Aminah', 'UPDATE_ROOM', 'Room 204 status changed to Clean'],
  ['2026-10-24 12:00', 'System', 'BACKUP', 'Daily database backup completed'],
];

const mockReports = [
  ['Monthly Revenue Report', 'Oct 2026', 'Rp 1.250.000.000', '2026-10-24', 'Generated'],
  ['Occupancy Report', 'Sep 2026', '85%', '2026-10-01', 'Generated'],
  ['Guest Demographics', 'Q3 2026', 'A4 PDF', '2026-10-05', 'Generated'],
];

export default function App() {
  const [activeModule, setActiveModule] = useState('dashboard');

  const renderContent = () => {
    switch (activeModule) {
      case 'dashboard': return <Dashboard />;
      case 'analytics': return <AnalyticsPage />;
      case 'reports': return <DataPage title="Reports" description="Generate and download business reports." columns={['Report Name', 'Period', 'Value', 'Generated On', 'Status']} data={mockReports} actionLabel="New Report" />;
      case 'hr': return <DataPage title="HR & Staff" description="Manage staff attendance and schedules." columns={['Staff Name', 'Department', 'Shift', 'Attendance', 'Time']} data={mockHR} actionLabel="Add Staff" />;
      case 'inventory': return <DataPage title="Inventory" description="Track stock levels and supplies." columns={['Item Code', 'Item Name', 'Category', 'Stock', 'Unit']} data={mockInventory} actionLabel="Add Item" />;
      case 'purchasing': return <DataPage title="Purchasing & Vendors" description="Manage purchase orders and vendors." columns={['PO No', 'Vendor', 'Items', 'Total', 'Status']} data={mockPurchasing} actionLabel="New PO" />;
      case 'integrations': return <DataPage title="Integrations" description="Manage external system connections." columns={['System', 'Provider', 'Status', 'Connected On']} data={mockIntegrations} actionLabel="Add Integration" />;
      case 'audit': return <DataPage title="Audit Logs" description="Track system activity and changes." columns={['Timestamp', 'User', 'Action', 'Details']} data={mockAudit} actionLabel="Export Logs" />;
      case 'reservations': return <DataPage title="Reservations" description="Manage room and venue bookings." columns={['Booking ID', 'Guest Name', 'Room/Event', 'Check In', 'Check Out', 'Status']} data={mockReservations} actionLabel="New Booking" />;
      case 'rooms': return <DataPage title="Room Management" description="Monitor room status and availability." columns={['Room No', 'Type', 'Floor', 'Status', 'Housekeeping']} data={mockRooms} actionLabel="Add Room" />;
      case 'guests': return <DataPage title="Guests & CRM" description="Customer relationship management." columns={['Name', 'Email', 'Phone', 'Membership', 'Last Stay']} data={mockGuests} actionLabel="Add Guest" />;
      case 'housekeeping': return <DataPage title="Housekeeping" description="Manage cleaning schedules and maintenance." columns={['Task ID', 'Room', 'Assigned To', 'Status', 'Priority']} data={mockHousekeeping} actionLabel="New Task" />;
      case 'venues': return <DataPage title="Venue Management" description="Manage ballrooms and meeting rooms." columns={['Venue Name', 'Capacity', 'Layout', 'Price/Day', 'Status']} data={mockVenues} actionLabel="Add Venue" />;
      case 'events': return <DataPage title="Event Calendar" description="View and manage scheduled events." columns={['Event Name', 'Client', 'Date', 'Venue', 'Status']} data={mockEvents} actionLabel="New Event" />;
      case 'quotations': return <DataPage title="Quotations" description="Manage event proposals and contracts." columns={['Quote No', 'Client', 'Event Type', 'Amount', 'Status']} data={mockQuotations} actionLabel="Create Quote" />;
      case 'rates': return <DataPage title="Revenue Management" description="Manage room rates and availability." columns={['Date', 'Room Type', 'Rate', 'Available', 'Min Stay']} data={mockRates} actionLabel="Update Rates" />;
      case 'pos': return <DataPage title="POS & Billing" description="Point of sale and billing transactions." columns={['Receipt No', 'Outlet', 'Items', 'Total', 'Payment Method']} data={mockPos} actionLabel="New Transaction" />;
      case 'finance': return <DataPage title="Finance" description="Financial reports and folios." columns={['Invoice No', 'Guest/Vendor', 'Amount', 'Date', 'Status']} data={mockFinance} actionLabel="Create Invoice" />;
      case 'users': return <DataPage title="Users & Roles" description="Manage system access and permissions." columns={['Name', 'Email', 'Role', 'Department', 'Status']} data={mockUsers} actionLabel="Add User" />;
      case 'settings': return <DataPage title="Settings" description="System configuration and preferences." columns={['Key', 'Value', 'Description', 'Last Updated']} data={mockSettings} actionLabel="Add Setting" />;
      default: return (
        <div className="generic-page">
          <div className="page-header">
            <div>
              <h2 className="page-header-title">Under Construction</h2>
              <p className="page-header-desc">The module "{activeModule}" is currently being developed.</p>
            </div>
          </div>
        </div>
      );
    }
  };

  return (
    <div className="layout">
      <aside className="sidebar">
        <div className="brand" style={{ padding: '24px 16px', display: 'flex', justifyContent: 'center' }}>
          <img src="/serenity-logo.png" alt="Serenity HMS" style={{ width: '200px', height: 'auto', objectFit: 'contain' }} />
        </div>
        <nav className="nav-menu">
          {NAVIGATION.map((section) => (
            <div key={section.group} className="nav-section">
              <div className="nav-group-title">{section.group}</div>
              {section.items.map((item) => (
                <button key={item.id} className={`nav-item ${activeModule === item.id ? 'active' : ''}`} onClick={() => setActiveModule(item.id)}>
                  <span className="nav-icon">{item.icon}</span>
                  <span className="nav-label">{item.label}</span>
                </button>
              ))}
            </div>
          ))}
        </nav>
      </aside>

      <main className="main-content">
        <header className="top-header">
          <div className="header-left">
            <img src="/iicc-logo-1.png" alt="IPB Convention Center" style={{ height: '36px', objectFit: 'contain' }} />
          </div>
          <div className="header-right">
            <div className="property-info">
              <span className="prop-label">PROPERTY</span>
              <span className="prop-name">IPB HOTEL</span>
            </div>
            <div className="date-info">
              <span className="prop-label">DATE</span>
              <span className="prop-name">{new Date().toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' }).toUpperCase()}</span>
            </div>
            <div className="user-avatar-small">A</div>
          </div>
        </header>

        <div className="dashboard-container">
          {renderContent()}
          <footer className="app-footer">
            <span>SERENITY HMS • IPB HOTEL & CONVENTION CENTER</span>
            <span>Executive Workspace • v1.0</span>
          </footer>
        </div>
      </main>
    </div>
  );
}
