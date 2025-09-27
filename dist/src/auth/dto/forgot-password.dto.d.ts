export declare class ForgotPasswordRequestDto {
    email?: string;
    phone?: string;
}
export declare class VerifyOtpDto {
    code: string;
    email?: string;
    phone?: string;
}
export declare class ResetPasswordDto {
    code: string;
    newPassword: string;
    email?: string;
    phone?: string;
}
