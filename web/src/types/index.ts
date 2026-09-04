export interface UserStats {
  wins: number;
  losses: number;
  winrate: number;
  currentStreak: number;
  bestStreak: number;
  points: number;
  rank: "Bronze" | "Silver" | "Gold" | "Elite" | "Legendary";
  rankPosition: number;
}

export interface User {
  uid: string;
  username: string;
  email: string;
  displayName?: string;
  avatarUrl?: string;
  bio?: string;
  country: string;
  region: string;
  teamId?: string;
  stats: UserStats;
  isPremium: boolean;
  createdAt: Date;
  lastActive: Date;
  isOnline: boolean;
}

export interface TeamStats {
  wins: number;
  losses: number;
  winrate: number;
  points: number;
  trophies: number;
}

export interface Team {
  id: string;
  name: string;
  logoUrl?: string;
  description?: string;
  ownerId: string;
  memberIds: string[];
  adminIds: string[];
  stats: TeamStats;
  country: string;
  region: string;
  createdAt: Date;
  isOpen: boolean;
}

export type ChallengeStatus =
  | "pending"
  | "accepted"
  | "declined"
  | "completed"
  | "cancelled"
  | "expired";

export interface Challenge {
  id: string;
  challengerId: string;
  opponentId: string;
  status: ChallengeStatus;
  winnerId?: string;
  challengerScore?: number;
  opponentScore?: number;
  message?: string;
  createdAt: Date;
  acceptedAt?: Date;
  completedAt?: Date;
  expiresAt?: Date;
}
