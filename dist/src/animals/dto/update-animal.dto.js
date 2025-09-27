"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateAnimalDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const create_animal_dto_1 = require("./create-animal.dto");
class UpdateAnimalDto extends (0, swagger_1.PartialType)(create_animal_dto_1.CreateAnimalDto) {
}
exports.UpdateAnimalDto = UpdateAnimalDto;
//# sourceMappingURL=update-animal.dto.js.map