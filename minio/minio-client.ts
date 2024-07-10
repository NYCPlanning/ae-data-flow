import * as Minio from 'minio';
import 'dotenv/config';

export const minioClient = new Minio.Client({
    endPoint: process.env.DO_SPACES_ENDPOINT_HTTP!,
    accessKey: process.env.DO_SPACES_ACCESS_KEY!,
    secretKey: process.env.DO_SPACES_SECRET_KEY!,
});
