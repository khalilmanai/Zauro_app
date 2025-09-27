declare const _default: () => {
    port: number;
    nodeEnv: string;
    apiPrefix: string;
    database: {
        url: string | undefined;
    };
    jwt: {
        secret: string | undefined;
        refreshSecret: string | undefined;
        expiresIn: string;
        refreshExpiresIn: string;
    };
    mailersend: {
        apiKey: string | undefined;
        from: string;
    };
    twilio: {
        accountSid: string | undefined;
        authToken: string | undefined;
        phoneNumber: string | undefined;
    };
    hedera: {
        accountId: string | undefined;
        privateKey: string | undefined;
        network: string;
        mirrorNodeUrl: string | undefined;
    };
    supabase: {
        url: string | undefined;
        anonKey: string | undefined;
        serviceRoleKey: string | undefined;
    };
    encryption: {
        key: string | undefined;
    };
    throttle: {
        ttl: number;
        limit: number;
    };
    otp: {
        expiresInMinutes: number;
        length: number;
    };
    upload: {
        maxFileSize: number;
        allowedFileTypes: string[];
    };
};
export default _default;
