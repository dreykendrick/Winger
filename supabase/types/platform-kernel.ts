// Winger Backend V2 - Shared Platform SDK & Kernel Interfaces

export type UserRole = 'CUSTOMER' | 'VENDOR' | 'AFFILIATE' | 'SUPPORT' | 'FINANCE_MANAGER' | 'ADMIN' | 'SUPER_ADMIN';
export type AccountStatus = 'PENDING_VERIFICATION' | 'ACTIVE' | 'SUSPENDED' | 'DEACTIVATED';
export type VerificationType = 'EMAIL' | 'PHONE' | 'IDENTITY_KYC' | 'BUSINESS' | 'VENDOR' | 'AFFILIATE';
export type InvitationStatus = 'PENDING' | 'ACCEPTED' | 'DECLINED' | 'EXPIRED' | 'REVOKED';
export type OutboxStatus = 'PENDING' | 'PROCESSING' | 'PUBLISHED' | 'FAILED';
export type NotificationChannel = 'IN_APP' | 'PUSH' | 'EMAIL' | 'SMS';

export interface WorkspaceContext {
  profile_id: string;
  workspace_id: string;
  workspace_name: string;
  user_role: UserRole;
  permissions: string[];
}

export interface EventMetadata {
  event_id: string;
  event_type: string;
  version: string;
  timestamp: string;
  correlation_id: string;
  workspace_id?: string;
}

export interface EventEnvelope<T = unknown> {
  metadata: EventMetadata;
  payload: T;
}

export interface ConfigurationItem<T = unknown> {
  key: string;
  value: T;
  description: string;
  is_public: boolean;
  workspace_id?: string;
}

export interface NotificationEnvelope {
  workspace_id?: string;
  profile_id: string;
  channel: NotificationChannel;
  title: string;
  body: string;
  data?: Record<string, unknown>;
}
