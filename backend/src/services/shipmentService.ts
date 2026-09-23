import fs from 'fs';
import path from 'path';
import { IShipment } from '../models/shipmentModel';

const DB_FILE = path.join(__dirname, '../../data/shipments.json');

function ensureDbFile(): void {
  const dir = path.dirname(DB_FILE);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  if (!fs.existsSync(DB_FILE)) {
    const initialShipments: IShipment[] = [
      {
        id: 'shp-1',
        trackingId: 'MAF-100-234-291',
        sender: 'Bunmi Tanny',
        receiver: 'Mercy',
        pickupLocation: 'Lagos, Nigeria',
        pickupCountry: 'NG',
        deliveryLocation: 'Oyo Nigeria',
        deliveryCountry: 'NG',
        amount: 3000,
        currency: 'NGN',
        status: 'In-Transit',
        paymentStatus: 'Paid',
        processingTimeHours: 10,
        createdAt: new Date().toISOString(),
        userId: 'usr-1',
      },
      {
        id: 'shp-2',
        trackingId: 'MAF-100-234-292',
        sender: 'Bunmi Tanny',
        receiver: 'Mercy',
        pickupLocation: 'Lagos, Nigeria',
        pickupCountry: 'NG',
        deliveryLocation: 'Oyo Nigeria',
        deliveryCountry: 'NG',
        amount: 3000,
        currency: 'NGN',
        status: 'Delayed',
        paymentStatus: 'Unpaid',
        processingTimeHours: 10,
        createdAt: new Date(Date.now() - 3600000).toISOString(),
        userId: 'usr-1',
      },
      {
        id: 'shp-3',
        trackingId: 'MAF-100-234-293',
        sender: 'Bunmi Tanny',
        receiver: 'Mercy',
        pickupLocation: 'Lagos, Nigeria',
        pickupCountry: 'NG',
        deliveryLocation: 'Abuja Nigeria',
        deliveryCountry: 'NG',
        amount: 5500,
        currency: 'NGN',
        status: 'In-Transit',
        paymentStatus: 'Paid',
        processingTimeHours: 8,
        createdAt: new Date(Date.now() - 7200000).toISOString(),
        userId: 'usr-1',
      },
      {
        id: 'shp-4',
        trackingId: 'MAF-100-234-294',
        sender: 'Bunmi Tanny',
        receiver: 'Emeka Obi',
        pickupLocation: 'Lagos, Nigeria',
        pickupCountry: 'NG',
        deliveryLocation: 'Port Harcourt Nigeria',
        deliveryCountry: 'NG',
        amount: 4200,
        currency: 'NGN',
        status: 'Delivered',
        paymentStatus: 'Paid',
        processingTimeHours: 24,
        createdAt: new Date(Date.now() - 86400000).toISOString(),
        userId: 'usr-1',
      },
    ];
    fs.writeFileSync(DB_FILE, JSON.stringify(initialShipments, null, 2), 'utf-8');
  }
}

function readShipments(): IShipment[] {
  ensureDbFile();
  try {
    const data = fs.readFileSync(DB_FILE, 'utf-8');
    return JSON.parse(data);
  } catch {
    return [];
  }
}

function writeShipments(shipments: IShipment[]): void {
  ensureDbFile();
  fs.writeFileSync(DB_FILE, JSON.stringify(shipments, null, 2), 'utf-8');
}

export class ShipmentService {
  static getShipments(userId?: string): IShipment[] {
    const all = readShipments();
    if (userId) {
      const userSpecific = all.filter((s) => s.userId === userId);
      return userSpecific.length > 0 ? userSpecific : all;
    }
    return all;
  }

  static getShipmentById(id: string): IShipment | null {
    const all = readShipments();
    return all.find((s) => s.id === id || s.trackingId === id) || null;
  }

  static payShipment(id: string): IShipment {
    const all = readShipments();
    const shipment = all.find((s) => s.id === id || s.trackingId === id);
    if (!shipment) {
      throw new Error('Shipment not found.');
    }
    shipment.paymentStatus = 'Paid';
    if (shipment.status === 'Delayed') {
      shipment.status = 'In-Transit';
    }
    writeShipments(all);
    return shipment;
  }
}
