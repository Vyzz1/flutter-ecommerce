import { FastifyReply } from "fastify";
import ArgumentError from "./AgrumentError";

export class ErrorResponse {
  constructor(
    public message: string,
    public status: number,
    public timestamp: Date
  ) {
    this.message = message;
    this.status = status;
    this.timestamp = timestamp;
  }

  static sendError(reply: FastifyReply, message: string, status = 400) {
    const er = new ErrorResponse(message, status, new Date());
    reply.status(status).send(er);
    return;
  }

  static sendServerError(reply: FastifyReply) {
    return this.sendError(reply, "Internal Server Error", 500);
  }

  static sendNotFound(reply: FastifyReply, message: string) {
    return this.sendError(reply, message, 404);
  }

  static sendErrorWithDetails(reply: FastifyReply, error: any) {
    console.error(error);
    if (error instanceof ArgumentError) {
      return ErrorResponse.sendError(
        reply,
        error.message,
        error.statusCode ?? 400
      );
    }
    return ErrorResponse.sendServerError(reply);
  }
}
