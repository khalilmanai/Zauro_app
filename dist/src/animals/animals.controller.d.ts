import { AnimalsService } from './animals.service';
import { CreateAnimalDto } from './dto/create-animal.dto';
import { UpdateAnimalDto } from './dto/update-animal.dto';
import { AnimalResponseDto } from './dto/animal-response.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
export declare class AnimalsController {
    private readonly animalsService;
    constructor(animalsService: AnimalsService);
    create(createAnimalDto: CreateAnimalDto, req: any, imageFile?: Express.Multer.File): Promise<AnimalResponseDto>;
    findAll(paginationDto: PaginationDto, ownerId?: string): Promise<{
        success: boolean;
        message: string;
        data: AnimalResponseDto[];
        pagination: {
            page: number;
            limit: number;
            total: number;
            totalPages: number;
        };
        timestamp: string;
    }>;
    findOne(id: string): Promise<AnimalResponseDto>;
    update(id: string, updateAnimalDto: UpdateAnimalDto, req: any): Promise<AnimalResponseDto>;
    remove(id: string, req: any): Promise<{
        message: string;
    }>;
    uploadImage(id: string, req: any, imageFile: Express.Multer.File): Promise<AnimalResponseDto>;
    uploadVetRecord(id: string, req: any, vetRecordFile: Express.Multer.File): Promise<AnimalResponseDto>;
}
