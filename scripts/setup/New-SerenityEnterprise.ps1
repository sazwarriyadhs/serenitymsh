[CmdletBinding()]
param(
    [string]$RootPath = 'D:\SERENITY-HMS',
    [switch]$ScaffoldFrameworks,
    [switch]$ApplyStarterScreens
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$RootPath = [IO.Path]::GetFullPath($RootPath)
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupRoot = "$RootPath-backups\enterprise-$Stamp"

function Ensure-Dir([string]$RelativePath) {
    $p = Join-Path $RootPath $RelativePath
    if (-not (Test-Path -LiteralPath $p -PathType Container)) {
        New-Item -ItemType Directory -Path $p -Force | Out-Null
    }
}
function Write-FileIfMissing([string]$RelativePath, [string]$Content) {
    $p = Join-Path $RootPath $RelativePath
    $parent = Split-Path -Parent $p
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    if (Test-Path -LiteralPath $p -PathType Leaf) {
        Write-Host "KEEP     $RelativePath" -ForegroundColor Yellow
        return
    }
    Set-Content -LiteralPath $p -Value $Content -Encoding utf8
    Write-Host "CREATE   $RelativePath" -ForegroundColor Green
}
function Backup-AndWrite([string]$RelativePath, [string]$Content) {
    $p = Join-Path $RootPath $RelativePath
    if (Test-Path -LiteralPath $p -PathType Leaf) {
        $dest = Join-Path $BackupRoot $RelativePath
        New-Item -ItemType Directory -Path (Split-Path -Parent $dest) -Force | Out-Null
        Copy-Item -LiteralPath $p -Destination $dest -Force
        Write-Host "BACKUP   $RelativePath -> $dest" -ForegroundColor Cyan
    }
    $parent = Split-Path -Parent $p
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    Set-Content -LiteralPath $p -Value $Content -Encoding utf8
    Write-Host "WRITE    $RelativePath" -ForegroundColor Green
}

Write-Host "`nSERENITY HMS ENTERPRISE - STRUCTURE GENERATOR" -ForegroundColor Cyan
Write-Host "Root: $RootPath"
New-Item -ItemType Directory -Path $RootPath -Force | Out-Null

$dirs = @(
 'apps/customer-mobile','apps/landing-page','apps/commander-web','apps/staff-portal',
 'backend/api/cmd/server','backend/api/internal/config','backend/api/internal/http/middleware',
 'backend/api/internal/platform','backend/api/internal/modules','backend/worker/cmd/worker',
 'backend/worker/internal/jobs','backend/ai-service/app/api','backend/ai-service/app/core',
 'backend/ai-service/app/providers','backend/ai-service/tests',
 'modules/identity','modules/properties','modules/pms','modules/booking','modules/ota-comparison',
 'modules/community','modules/housekeeping','modules/maintenance','modules/pos','modules/finance',
 'modules/convention-events','modules/crm','modules/ai-concierge','modules/reputation',
 'modules/revenue-intelligence','modules/loyalty',
 'integration-hub/core','integration-hub/contracts','integration-hub/connectors/pms',
 'integration-hub/connectors/channel-manager','integration-hub/connectors/ota',
 'integration-hub/connectors/booking-engine','integration-hub/connectors/pos',
 'integration-hub/connectors/reputation','integration-hub/webhooks','integration-hub/mapping',
 'integration-hub/sync','integration-hub/retry','integration-hub/dead-letter',
 'packages/contracts/openapi','packages/shared-types','packages/validation','packages/ui',
 'database/migrations','database/seeds/development','database/seeds/test','database/schemas','database/queries',
 'infrastructure/docker','infrastructure/environments/development','infrastructure/environments/staging',
 'infrastructure/environments/production','infrastructure/monitoring','infrastructure/ci',
 'docs/architecture/decisions','docs/api','docs/database','docs/integrations','docs/security',
 'docs/runbooks','docs/uat','tests/unit','tests/integration','tests/contract','tests/e2e',
 'tests/performance','tests/fixtures','scripts/setup','scripts/database','scripts/development',
 'scripts/validation','storage'
)
foreach ($d in $dirs) { Ensure-Dir $d }

Write-FileIfMissing 'README.md' @'
# Serenity HMS Enterprise

Platform digital untuk IPB Convention Hotel dan IPB International Convention Center.

## Produk
- Customer Mobile (Flutter): komunitas IPB Hotel, OTA price comparison, dan pilihan Member / Non-Member.
- Official Landing Page (Next.js): informasi hotel/venue, lead capture, dan request for quotation.
- Commander Dashboard (Next.js): executive overview, sales pipeline, reservasi, event, integrasi, dan operasional.
- Staff Portal (Next.js): tugas dan workflow staf.

## Arsitektur
- Go modular-monolith API dan background worker.
- Python/FastAPI untuk AI service.
- PostgreSQL untuk data transaksional.
- Provider adapters terisolasi di Integration Hub.

## Aturan
- Satu system of record untuk setiap domain.
- Jangan mengklaim harga OTA live tanpa sumber yang sah dan timestamp.
- Jangan menyimpan credential di source control.
- Booking/finance/integration wajib idempotent dan diaudit.
- Member dan Non-Member adalah pilihan pelanggan; registrasi tidak boleh menjadi penghalang tarif publik.
'@
Write-FileIfMissing '.gitignore' @'
.env
.env.*
!.env.example
*.pem
*.key
secrets/
credentials/
node_modules/
dist/
build/
coverage/
.dart_tool/
.flutter-plugins*
*.log
.vscode/
.idea/
.DS_Store
Thumbs.db
storage/*
!storage/.gitkeep
'@
Write-FileIfMissing '.editorconfig' @'
root = true
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 2
[*.go]
indent_style = tab
[*.md]
trim_trailing_whitespace = false
'@
Write-FileIfMissing '.env.example' @'
APP_ENV=development
APP_NAME=serenity-hms
API_PORT=8091
DATABASE_URL=postgres://serenity:CHANGE_ME@localhost:5434/serenity?sslmode=disable
AI_SERVICE_URL=http://localhost:8000
LOG_LEVEL=debug
# Add local secrets to .env; never commit them.
'@
Write-FileIfMissing 'docs/architecture/SYSTEM-OVERVIEW.md' @'
# System Overview

## Product goals
1. Customer Mobile builds the IPB Hotel community, supports OTA price comparison, and lets customers choose Member or Non-Member booking.
2. Landing Page acquires hotel guests and convention/event clients.
3. Commander Dashboard gives management one view of business and operations.

## Architecture
Start with a Go modular monolith for transactional business domains. Run background workers separately. Use Python/FastAPI for AI capabilities. Use PostgreSQL with reviewed migrations. Keep provider integrations behind explicit adapters.

## Booking and pricing policy
Every offer must show provider, room/occupancy/date matching, total price basis, tax/fee inclusion, cancellation terms, checked-at timestamp, source status, and booking link. If a provider cannot be queried, show unavailable/not connected; never fabricate a live rate. Member rates and benefits only appear when configured and verified. Non-Member public booking remains available.

## Integration lifecycle
Receive -> Authenticate -> Validate -> Deduplicate -> Normalize -> Process -> Audit -> Retry/dead-letter.

## Security
Least privilege, property-level authorization, secret references, audit events, privacy/retention policy, tested backups, and no raw payment-card storage.
'@
Write-FileIfMissing 'docs/integrations/INTEGRATION-MATRIX.md' @'
# Integration Matrix

Track provider, business owner, docs URL, authentication, sandbox, authorized capabilities, rate limits, webhooks, mapping, retention, approval status, last successful test, and escalation contact.

Potential channels to verify: Agoda, Booking.com, Traveloka, Tiket.com, Expedia/Hotels.com, official website/booking engine, PMS and Channel Manager. Existing extranet access does not itself prove API access.
'@
Write-FileIfMissing 'docs/uat/ACCEPTANCE-CRITERIA.md' @'
# Initial Acceptance Criteria
- Customer can choose Member or Non-Member.
- Non-Member can access public rates without mandatory account creation, subject to booking-channel capability.
- OTA results show provider status and checked-at time; no fabricated rates.
- Member pricing and benefits are shown only when configured and validated.
- Landing-page inquiry is captured with consent and source attribution.
- Commander metrics identify source and freshness.
- Sensitive management actions are role-controlled and audited.
- Integrations are idempotent and observable.
'@

# Optional framework scaffolding. It only initializes projects whose manifests do not exist.
if ($ScaffoldFrameworks) {
    $flutter = Get-Command flutter -ErrorAction SilentlyContinue
    if (-not $flutter) { Write-Warning 'Flutter CLI not found; skipping Flutter scaffold.' }
    else {
        $mobile = Join-Path $RootPath 'apps/customer-mobile'
        if (-not (Test-Path (Join-Path $mobile 'pubspec.yaml'))) {
            flutter create --project-name ipb_hotel_customer --platforms android,ios,web $mobile
            if ($LASTEXITCODE -ne 0) { throw 'flutter create failed.' }
        } else { Write-Host 'KEEP     existing Flutter project' -ForegroundColor Yellow }
    }
    $npm = Get-Command npm -ErrorAction SilentlyContinue
    if (-not $npm) { Write-Warning 'npm not found; skipping Next.js scaffolds.' }
    else {
        foreach ($app in @(@{Path='apps/landing-page';Name='ipb-hotel-landing'},@{Path='apps/commander-web';Name='serenity-commander'})) {
            $target = Join-Path $RootPath $app.Path
            if (-not (Test-Path (Join-Path $target 'package.json'))) {
                npx --yes create-next-app@latest $target --typescript --tailwind --eslint --app --src-dir --use-npm --import-alias '@/*'
                if ($LASTEXITCODE -ne 0) { throw "Next.js scaffold failed for $($app.Path)." }
            } else { Write-Host "KEEP     existing Next.js project: $($app.Path)" -ForegroundColor Yellow }
        }
    }
}

# Optional starter screens: existing source is backed up before being replaced.
if ($ApplyStarterScreens) {
    $mobileMain = Join-Path $RootPath 'apps/customer-mobile/lib/main.dart'
    if (-not (Test-Path (Join-Path (Split-Path -Parent $mobileMain) '.'))) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $mobileMain) -Force | Out-Null
    }
    $mobileSource = @'
import 'package:flutter/material.dart';

void main() => runApp(const IPBHotelApp());

class IPBHotelApp extends StatelessWidget {
  const IPBHotelApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'IPB Hotel Community',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF174A3A)), useMaterial3: true),
    home: const IPBHomePage(),
  );
}

class IPBHomePage extends StatefulWidget {
  const IPBHomePage({super.key});
  @override
  State<IPBHomePage> createState() => _IPBHomePageState();
}

class _IPBHomePageState extends State<IPBHomePage> {
  DateTime checkIn = DateTime.now().add(const Duration(days: 7));
  DateTime checkOut = DateTime.now().add(const Duration(days: 9));
  int guests = 2;
  String bookingChoice = 'guest';
  int tab = 0;
  String dateLabel(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final pages = [home(), community(), const SimplePage(title: 'Events at IPB', subtitle: 'Discover upcoming hotel and convention events.'), const SimplePage(title: 'My IPB', subtitle: 'Your profile, reservations, and member benefits.')];
    return Scaffold(
      appBar: AppBar(title: const Text('IPB HOTEL', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))]),
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Discover'), NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Community'), NavigationDestination(icon: Icon(Icons.event_outlined), label: 'Events'), NavigationDestination(icon: Icon(Icons.person_outline), label: 'My IPB')]),
    );
  }

  Widget home() => ListView(padding: const EdgeInsets.all(18), children: [
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF123D32), Color(0xFF28745A)])), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('WELCOME TO IPB', style: TextStyle(color: Colors.white70, letterSpacing: 2)), SizedBox(height: 10), Text('Stay connected.\nStay inspired.', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.bold)), SizedBox(height: 8), Text('Your hotel stay, convention events, and community in one place.', style: TextStyle(color: Colors.white70))]),),
    const SizedBox(height: 22), const Text('Find your stay', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.login), title: const Text('Check-in'), subtitle: Text(dateLabel(checkIn)), trailing: const Icon(Icons.calendar_month), onTap: () async { final d = await showDatePicker(context: context, initialDate: checkIn, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730))); if (d != null) setState(() { checkIn = d; if (!checkOut.isAfter(d)) checkOut = d.add(const Duration(days: 1)); }); }),
      ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.logout), title: const Text('Check-out'), subtitle: Text(dateLabel(checkOut)), trailing: const Icon(Icons.calendar_month), onTap: () async { final d = await showDatePicker(context: context, initialDate: checkOut, firstDate: checkIn.add(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 730))); if (d != null) setState(() => checkOut = d); }),
      Row(children: [const Icon(Icons.people_outline), const SizedBox(width: 12), const Expanded(child: Text('Guests')), IconButton(onPressed: guests > 1 ? () => setState(() => guests--) : null, icon: const Icon(Icons.remove_circle_outline)), Text('$guests'), IconButton(onPressed: guests < 8 ? () => setState(() => guests++) : null, icon: const Icon(Icons.add_circle_outline))]),
      const SizedBox(height: 8), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => BookingOptions(checkIn: checkIn, checkOut: checkOut, guests: guests)), icon: const Icon(Icons.compare_arrows), label: const Text('Compare OTA Prices')),
    ]))),
    const SizedBox(height: 20), const Text('Choose how you book', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
    ChoiceCard(icon: Icons.workspace_premium_outlined, title: 'IPB Hotel Member', subtitle: 'Sign in or join to view eligible member rates and benefits.', buttonText: 'Continue as Member', highlighted: true, onTap: () => showChoice('Member')),
    const SizedBox(height: 10), ChoiceCard(icon: Icons.person_outline, title: 'Non-Member / Guest', subtitle: 'Continue with public rates. No membership required to explore.', buttonText: 'Continue as Guest', highlighted: false, onTap: () => showChoice('Non-Member')),
    const SizedBox(height: 22), const Text('IPB Hotel Community', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('Discover experiences, connect through events, and keep up with the IPB hospitality community.'), const SizedBox(height: 12), OutlinedButton.icon(onPressed: () => setState(() => tab = 1), icon: const Icon(Icons.groups_outlined), label: const Text('Explore Community')),
    const SizedBox(height: 18), const Text('OTA rates are shown only when a verified data source is connected. Prices and availability are not live in this starter screen.', style: TextStyle(fontSize: 12, color: Colors.grey)),
  ]);

  Widget community() => ListView(padding: const EdgeInsets.all(18), children: const [Text('IPB Hotel Community', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)), SizedBox(height: 8), Text('A place to discover hotel experiences, convention events, and member updates.'), SizedBox(height: 18), CommunityTile(icon: Icons.event_available, title: 'Events & Meetups', subtitle: 'Explore events at IPB Convention Hotel and IPB International Convention Center.'), CommunityTile(icon: Icons.card_giftcard, title: 'Member Benefits', subtitle: 'See eligible benefits and rewards after membership rules are configured.'), CommunityTile(icon: Icons.forum_outlined, title: 'Community Stories', subtitle: 'Community posts and member interactions will be enabled in a later API-connected release.')]);

  void showChoice(String choice) => showDialog<void>(context: context, builder: (context) => AlertDialog(title: Text('$choice booking'), content: Text(choice == 'Member' ? 'Member sign-in and verified member-rate lookup will be connected to the Serenity API.' : 'Public-rate search can continue without membership. Final booking depends on the connected booking channel.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))]));
}

class BookingOptions extends StatelessWidget {
  const BookingOptions({super.key, required this.checkIn, required this.checkOut, required this.guests});
  final DateTime checkIn; final DateTime checkOut; final int guests;
  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Wrap(runSpacing: 12, children: [const Text('Compare available OTA offers', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text('${checkIn.day}/${checkIn.month}/${checkIn.year} – ${checkOut.day}/${checkOut.month}/${checkOut.year} · $guests guests'), const Text('Provider connection status', style: TextStyle(fontWeight: FontWeight.bold)), const ProviderTile(name: 'Agoda', status: 'Not connected'), const ProviderTile(name: 'Booking.com', status: 'Not connected'), const ProviderTile(name: 'Traveloka', status: 'Not connected'), const ProviderTile(name: 'Tiket.com', status: 'Not connected'), const ProviderTile(name: 'Expedia / Hotels.com', status: 'Not connected'), const Text('No live prices are displayed until authorized provider feeds or APIs are configured.', style: TextStyle(color: Colors.grey, fontSize: 12))])));
}

class ProviderTile extends StatelessWidget { const ProviderTile({super.key, required this.name, required this.status}); final String name; final String status; @override Widget build(BuildContext context) => ListTile(leading: const Icon(Icons.hotel_outlined), title: Text(name), trailing: Text(status, style: const TextStyle(color: Colors.orange, fontSize: 12))); }
class ChoiceCard extends StatelessWidget { const ChoiceCard({super.key, required this.icon, required this.title, required this.subtitle, required this.buttonText, required this.highlighted, required this.onTap}); final IconData icon; final String title, subtitle, buttonText; final bool highlighted; final VoidCallback onTap; @override Widget build(BuildContext context) => Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: highlighted ? const Color(0xFF28745A) : Colors.black12)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 30, color: highlighted ? const Color(0xFF28745A) : null), const SizedBox(height: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 4), Text(subtitle), const SizedBox(height: 12), SizedBox(width: double.infinity, child: highlighted ? FilledButton(onPressed: onTap, child: Text(buttonText)) : OutlinedButton(onPressed: onTap, child: Text(buttonText)))]))); } }
class CommunityTile extends StatelessWidget { const CommunityTile({super.key, required this.icon, required this.title, required this.subtitle}); final IconData icon; final String title, subtitle; @override Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(subtitle))); }
class SimplePage extends StatelessWidget { const SimplePage({super.key, required this.title, required this.subtitle}); final String title, subtitle; @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.event_note, size: 56), const SizedBox(height: 12), Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center)]))); }
'@
    Backup-AndWrite 'apps/customer-mobile/lib/main.dart' $mobileSource

    $landing = @'
import Link from 'next/link';

const services = [
  { title: 'Stay at IPB Convention Hotel', text: 'Explore accommodation, guest services, and stay options.' },
  { title: 'Meet at IPB International Convention Center', text: 'Plan conferences, seminars, corporate gatherings, and special events.' },
  { title: 'Plan your event', text: 'Share your date, estimated attendance, venue setup, and catering needs.' },
];
export default function Home() {
  return <main className="min-h-screen bg-[#f6f7f4] text-slate-900">
    <header className="flex items-center justify-between px-6 py-5 md:px-12"><div><p className="text-xs tracking-[.25em] text-emerald-800">IPB HOSPITALITY</p><h1 className="text-xl font-bold">IPB Convention Hotel & Center</h1></div><Link className="rounded-full bg-emerald-900 px-5 py-3 text-sm font-semibold text-white" href="#inquiry">Request a Quote</Link></header>
    <section className="bg-gradient-to-br from-emerald-950 via-emerald-900 to-teal-800 px-6 py-24 text-white md:px-16"><p className="mb-4 text-sm uppercase tracking-[.3em] text-emerald-200">Stay · Connect · Convene</p><h2 className="max-w-4xl text-4xl font-bold leading-tight md:text-6xl">A place for meaningful stays and memorable gatherings.</h2><p className="mt-6 max-w-2xl text-lg text-emerald-50">Discover hospitality, meetings, and event possibilities at IPB Convention Hotel and IPB International Convention Center.</p><div className="mt-8 flex flex-wrap gap-3"><Link href="#stay" className="rounded-full bg-white px-6 py-3 font-semibold text-emerald-950">Explore Stay & Venue</Link><Link href="#inquiry" className="rounded-full border border-white/50 px-6 py-3 font-semibold">Plan an Event</Link></div></section>
    <section id="stay" className="grid gap-5 px-6 py-16 md:grid-cols-3 md:px-12">{services.map(s=><article key={s.title} className="rounded-2xl border border-slate-200 bg-white p-7 shadow-sm"><h3 className="text-xl font-bold">{s.title}</h3><p className="mt-3 leading-7 text-slate-600">{s.text}</p></article>)}</section>
    <section id="inquiry" className="px-6 pb-20 md:px-12"><div className="rounded-3xl bg-white p-8 shadow-sm md:p-12"><p className="text-sm font-semibold uppercase tracking-widest text-emerald-800">Sales inquiry</p><h2 className="mt-2 text-3xl font-bold">Tell us what you are planning</h2><p className="mt-3 max-w-2xl text-slate-600">This starter page demonstrates the lead-generation destination. Connect the form to the Serenity CRM API before collecting real customer data.</p><div className="mt-6 flex flex-wrap gap-3"><a className="rounded-full bg-emerald-900 px-6 py-3 font-semibold text-white" href="https://www.ipbconventioncenter.com/" target="_blank" rel="noreferrer">Visit Official Convention Center Site</a><a className="rounded-full border border-slate-300 px-6 py-3 font-semibold" href="mailto:">Contact Sales (configure email)</a></div></div></section>
    <footer className="border-t border-slate-200 px-6 py-6 text-sm text-slate-500 md:px-12">Serenity HMS Enterprise · Digital experience concept for IPB hospitality.</footer>
  </main>;
}
'@
    Backup-AndWrite 'apps/landing-page/src/app/page.tsx' $landing

    $commander = @'
const metrics = [
  { label: 'Room Occupancy', value: '—', note: 'Connect PMS data source' },
  { label: 'Reservations', value: '—', note: 'Awaiting reservation integration' },
  { label: 'Open Sales Leads', value: '—', note: 'Connect CRM pipeline' },
  { label: 'Upcoming Events', value: '—', note: 'Connect venue calendar' },
];
const areas = [
  ['Reservations & PMS', 'Room status, arrivals, departures, and reservation sync.'],
  ['OTA Price Intelligence', 'Provider connection health, rate freshness, and comparable offers.'],
  ['Convention & Events', 'Venue availability, leads, quotations, and event operations.'],
  ['Community & Loyalty', 'Membership, engagement, eligible rewards, and repeat visits.'],
  ['Housekeeping & Maintenance', 'Room readiness, task assignments, and maintenance incidents.'],
  ['Finance & Revenue', 'Reconciliation, revenue metrics, and approval-controlled insights.'],
];
export default function Home() {
 return <main className="min-h-screen bg-slate-950 text-slate-100"><aside className="border-b border-white/10 px-6 py-5 md:px-10"><p className="text-xs tracking-[.3em] text-amber-300">SERENITY HMS ENTERPRISE</p><div className="mt-2 flex flex-wrap items-end justify-between gap-3"><div><h1 className="text-3xl font-bold">Commander Dashboard</h1><p className="mt-1 text-slate-400">IPB Convention Hotel · IPB International Convention Center</p></div><span className="rounded-full border border-amber-300/30 px-3 py-1 text-xs text-amber-200">DEVELOPMENT SCAFFOLD</span></div></aside>
 <section className="px-6 py-8 md:px-10"><div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">{metrics.map(m=><article key={m.label} className="rounded-2xl border border-white/10 bg-white/[.04] p-5"><p className="text-sm text-slate-400">{m.label}</p><p className="mt-3 text-3xl font-semibold">{m.value}</p><p className="mt-2 text-xs text-slate-500">{m.note}</p></article>)}</div>
 <div className="mt-10 flex items-center justify-between"><div><h2 className="text-xl font-bold">Command Modules</h2><p className="mt-1 text-sm text-slate-400">Operational areas to connect through authorized APIs.</p></div></div><div className="mt-4 grid gap-4 md:grid-cols-2 xl:grid-cols-3">{areas.map(a=><article key={a[0]} className="rounded-2xl border border-white/10 bg-slate-900 p-5"><div className="flex items-center justify-between gap-3"><h3 className="font-semibold">{a[0]}</h3><span className="h-2 w-2 rounded-full bg-amber-300"/></div><p className="mt-3 text-sm leading-6 text-slate-400">{a[1]}</p><p className="mt-4 text-xs uppercase tracking-wider text-amber-200">Awaiting verified data source</p></article>)}</div>
 <p className="mt-8 rounded-xl border border-amber-300/20 bg-amber-300/5 p-4 text-sm text-amber-100">No live business metrics are fabricated. Connect the backend, authorize integrations, and define each metric before using this dashboard for operational decisions.</p></section></main>;
}
'@
    Backup-AndWrite 'apps/commander-web/src/app/page.tsx' $commander

    Write-Host "`nStarter screens written. Existing files, if any, are backed up under: $BackupRoot" -ForegroundColor Cyan
}

Write-Host "`nFolder structure ready." -ForegroundColor Green
if ($ScaffoldFrameworks) {
    Write-Host 'Framework scaffold option was enabled.'
    Write-Host 'Next.js starter screens require apps created with create-next-app (src/app/page.tsx).'
}
if ($ApplyStarterScreens) {
    Write-Host 'Run Flutter analyzer and web build next; review UI and connect APIs only after tests.'
}
Write-Host "`nSuggested verification:"
Write-Host "  Get-ChildItem '$RootPath\apps'"
Write-Host "  cd '$RootPath\apps\customer-mobile'; flutter pub get; dart format lib; flutter analyze; flutter run -d chrome --web-port 8095"
Write-Host "  cd '$RootPath\apps\landing-page'; npm run dev"
Write-Host "  cd '$RootPath\apps\commander-web'; npm run dev"
