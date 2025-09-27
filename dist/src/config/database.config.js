"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createPrismaClient = void 0;
const client_1 = require("@prisma/client");
const createPrismaClient = (configService) => {
    return new client_1.PrismaClient({
        datasources: {
            db: {
                url: configService.get('database.url'),
            },
        },
        log: configService.get('nodeEnv') === 'development' ? ['query', 'info', 'warn', 'error'] : ['error'],
    });
};
exports.createPrismaClient = createPrismaClient;
//# sourceMappingURL=database.config.js.map