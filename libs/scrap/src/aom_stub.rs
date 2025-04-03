#![allow(non_camel_case_types)]
#![allow(non_snake_case)]
#![allow(non_upper_case_globals)]
#![allow(improper_ctypes)]
#![allow(dead_code)]

use hbb_common::{
    anyhow::{anyhow, Context},
    bytes::Bytes,
    log,
    message_proto::{Chroma, EncodedVideoFrame, EncodedVideoFrames, VideoFrame},
    ResultType,
};
use std::{ptr, slice};
use crate::{codec::EncoderApi, EncodeFrame, STRIDE_ALIGN};
use crate::{common::GoogleImage, Result, Error};
use crate::{EncodeInput, EncodeYuvFormat, Pixfmt};

// 空的结构体和枚举，用于替代原始aom库中的类型
pub struct aom_codec_ctx_t {}
pub struct aom_codec_enc_cfg_t {}
pub struct aom_image_t {}
pub type aom_codec_iter_t = *mut std::ffi::c_void;

// 辅助常量
pub const AOM_CODEC_OK: i32 = 0;
pub const AOM_CODEC_ERROR: i32 = 1;

#[derive(Clone, Copy, Debug)]
pub struct AomEncoderConfig {
    pub width: u32,
    pub height: u32,
    pub quality: f32,
    pub keyframe_interval: Option<usize>,
}

pub struct AomEncoder {
    width: usize,
    height: usize,
    i444: bool,
    yuvfmt: EncodeYuvFormat,
}

// 模拟AOM编码器
impl EncoderApi for AomEncoder {
    fn new(cfg: crate::codec::EncoderCfg, i444: bool) -> ResultType<Self>
    where
        Self: Sized,
    {
        match cfg {
            crate::codec::EncoderCfg::AOM(config) => {
                log::warn!("AOM encoder is not available: using stub implementation");
                let yuvfmt = EncodeYuvFormat {
                    pixfmt: if i444 { Pixfmt::I444 } else { Pixfmt::I420 },
                    w: config.width as _,
                    h: config.height as _,
                    stride: vec![config.width as usize, config.width as usize / 2, config.width as usize / 2],
                    u: (config.width * config.height) as usize,
                    v: (config.width * config.height * 5 / 4) as usize,
                };
                
                Ok(Self {
                    width: config.width as _,
                    height: config.height as _,
                    i444,
                    yuvfmt,
                })
            }
            _ => Err(anyhow!("encoder type mismatch")),
        }
    }

    fn encode_to_message(&mut self, _input: EncodeInput, _ms: i64) -> ResultType<VideoFrame> {
        Err(anyhow!("AOM encoder is not available"))
    }

    fn yuvfmt(&self) -> crate::EncodeYuvFormat {
        self.yuvfmt.clone()
    }

    #[cfg(feature = "vram")]
    fn input_texture(&self) -> bool {
        false
    }

    fn set_quality(&mut self, _ratio: f32) -> ResultType<()> {
        Err(anyhow!("AOM encoder is not available"))
    }

    fn bitrate(&self) -> u32 {
        0
    }

    fn support_changing_quality(&self) -> bool {
        false
    }

    fn latency_free(&self) -> bool {
        true
    }

    fn is_hardware(&self) -> bool {
        false
    }

    fn disable(&self) {}
}

impl AomEncoder {
    // 静态方法，用于创建一个空的帧集合
    pub fn create_video_frame(_frames: Vec<EncodedVideoFrame>) -> VideoFrame {
        VideoFrame::default()
    }

    // 静态方法，用于从编码帧创建视频帧
    fn create_frame(_frame: &EncodeFrame) -> EncodedVideoFrame {
        EncodedVideoFrame::default()
    }

    // 静态方法，用于计算比特率
    fn bitrate(width: u32, height: u32, ratio: f32) -> u32 {
        crate::codec::base_bitrate(width, height)
    }

    // 静态方法，用于计算质量值
    fn calc_q_values(ratio: f32) -> (u32, u32) {
        let q = ((1.0 - ratio) * 60.0) as u32;
        (q, q)
    }
}

pub struct EncodeFrames<'a> {
    iter: aom_codec_iter_t,
}

impl<'a> Iterator for EncodeFrames<'a> {
    type Item = EncodeFrame<'a>;
    fn next(&mut self) -> Option<Self::Item> {
        None
    }
}

pub struct AomDecoder {}

impl AomDecoder {
    pub fn new() -> Result<Self> {
        log::warn!("AOM decoder is not available: using stub implementation");
        Err(Error::FailedCall("AOM decoder is not available".to_string()))
    }

    pub fn decode(&mut self, _data: &[u8]) -> Result<DecodeFrames> {
        Err(Error::FailedCall("AOM decoder is not available".to_string()))
    }

    pub fn flush(&mut self) -> Result<DecodeFrames> {
        Err(Error::FailedCall("AOM decoder is not available".to_string()))
    }
}

pub struct DecodeFrames<'a> {
    iter: aom_codec_iter_t,
}

impl<'a> Iterator for DecodeFrames<'a> {
    type Item = Image;
    fn next(&mut self) -> Option<Self::Item> {
        None
    }
}

pub struct Image(*mut aom_image_t);

impl Image {
    pub fn new() -> Self {
        Self(ptr::null_mut())
    }

    pub fn is_null(&self) -> bool {
        true
    }

    pub fn format(&self) -> i32 {
        0
    }

    pub fn inner(&self) -> &aom_image_t {
        panic!("AOM decoder is not available")
    }
}

impl GoogleImage for Image {
    fn width(&self) -> usize {
        0
    }

    fn height(&self) -> usize {
        0
    }

    fn stride(&self) -> Vec<i32> {
        vec![]
    }

    fn planes(&self) -> Vec<*mut u8> {
        vec![]
    }

    fn chroma(&self) -> Chroma {
        Chroma::I420
    }
} 