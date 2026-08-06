// Winger Backend V2 - Pluggable Payment Gateway Adapter Architecture
import { verifyHmacSha256 } from './hmac.ts';

export interface CreateIntentParams {
  sessionId: string;
  orderReference: string;
  amount: number;
  currency: string;
  customerPhone?: string;
  redirectUrl?: string;
}

export interface IntentResult {
  gatewayRef: string;
  paymentUrl: string;
  clientSecret?: string;
}

export interface WebhookPayload {
  orderReference: string;
  gatewayTransactionId: string;
  status: 'SUCCEEDED' | 'FAILED' | 'CANCELLED';
  amount: number;
  currency: string;
  timestamp: string;
}

export interface PaymentGatewayAdapter {
  createPaymentIntent(params: CreateIntentParams): Promise<IntentResult>;
  verifyWebhookSignature(rawBody: string, signature: string, secret: string): Promise<boolean>;
  parseWebhookPayload(rawBody: string): WebhookPayload;
}

// 1. Selcom Payment Gateway Adapter
export class SelcomAdapter implements PaymentGatewayAdapter {
  async createPaymentIntent(params: CreateIntentParams): Promise<IntentResult> {
    const gatewayRef = `SELCOM_${Date.now()}_${crypto.randomUUID().slice(0, 6)}`;
    const paymentUrl = `https://checkout.selcom.co/pay?session=${params.orderReference}`;
    return { gatewayRef, paymentUrl };
  }

  async verifyWebhookSignature(rawBody: string, signature: string, secret: string): Promise<boolean> {
    return await verifyHmacSha256(rawBody, signature, secret);
  }

  parseWebhookPayload(rawBody: string): WebhookPayload {
    const json = JSON.parse(rawBody);
    return {
      orderReference: json.order_id || json.order_reference,
      gatewayTransactionId: json.trans_id || json.transaction_id,
      status: json.payment_status === 'COMPLETED' ? 'SUCCEEDED' : 'FAILED',
      amount: Number(json.amount || 0),
      currency: json.currency || 'TZS',
      timestamp: json.timestamp || new Date().toISOString(),
    };
  }
}

// 2. Meetpay Payment Gateway Adapter (Legacy Compatibility)
export class MeetpayAdapter implements PaymentGatewayAdapter {
  async createPaymentIntent(params: CreateIntentParams): Promise<IntentResult> {
    const gatewayRef = `MEETPAY_${Date.now()}_${crypto.randomUUID().slice(0, 6)}`;
    const paymentUrl = `https://pay.meetpay.co/checkout?ref=${params.orderReference}`;
    return { gatewayRef, paymentUrl };
  }

  async verifyWebhookSignature(rawBody: string, signature: string, secret: string): Promise<boolean> {
    return await verifyHmacSha256(rawBody, signature, secret);
  }

  parseWebhookPayload(rawBody: string): WebhookPayload {
    const json = JSON.parse(rawBody);
    return {
      orderReference: json.reference || json.order_id,
      gatewayTransactionId: json.mp_trans_id || json.id,
      status: json.status === 'SUCCESS' ? 'SUCCEEDED' : 'FAILED',
      amount: Number(json.amount || 0),
      currency: json.currency || 'TZS',
      timestamp: json.created_at || new Date().toISOString(),
    };
  }
}

// 3. Gateway Adapter Factory
export class GatewayAdapterFactory {
  static getAdapter(provider: string): PaymentGatewayAdapter {
    switch (provider.toUpperCase()) {
      case 'SELCOM':
        return new SelcomAdapter();
      case 'MEETPAY':
        return new MeetpayAdapter();
      default:
        return new SelcomAdapter();
    }
  }
}
