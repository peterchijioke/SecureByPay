import { z } from 'zod';

const firstNameSchema = z.string().min(1, 'First name must not be empty.').max(50, 'First name must be at most 50 characters.').trim();
const lastNameSchema = z.string().min(1, 'Last name must not be empty.').max(50, 'Last name must be at most 50 characters.').trim();
const emailSchema = z.string().email('Please enter a valid email address.').toLowerCase().trim();
const phoneSchema = z.string().min(7, 'Phone number must be at least 7 digits.').max(20, 'Phone number must be at most 20 characters.').regex(/^\+?[\d\s\-().]+$/, 'Phone number contains invalid characters.').trim();
const passwordSchema = z.string().min(6, 'Password must be at least 6 characters long.').max(128, 'Password must be at most 128 characters.');

export const registerSchema = z.object({
  firstName: firstNameSchema,
  lastName: lastNameSchema,
  email: emailSchema,
  phone: phoneSchema,
  password: passwordSchema,
  role: z.enum(['user', 'admin']).optional().default('user'),
});

export type RegisterInput = z.infer<typeof registerSchema>;

export const loginSchema = z.object({
  email: emailSchema,
  password: z.string().min(1, 'Password must not be empty.'),
});

export type LoginInput = z.infer<typeof loginSchema>;

export const fundWalletSchema = z.object({
  amount: z
    .number('Amount must be a number.')
    .positive('Amount must be a positive number.')
    .max(10_000_000, 'Amount must not exceed ₦10,000,000 per transaction.'),
});

export type FundWalletInput = z.infer<typeof fundWalletSchema>;

export function formatZodErrors(error: z.ZodError): string[] {
  return error.issues.map((issue) => issue.message);
}
